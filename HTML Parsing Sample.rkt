#lang racket

; Author - Todd Sharpe
; Rant
; Html processing in racket isn't too friendly to a new user, and required not only and understanding of how the networking works - urls, incoming ports, port processors, but also WTF a struct means in racket, and how each struct defines a metric buttload of other procedures, only a handful are usefull.
; Therefore, this may not be the "best" way, but it works - lets all just hope the nhl doesn't change their source code
; /Rant

; Define an easy object to hold the data
(define (make-game date visitor home score decision time network)
  (list 'game date visitor home score decision time network))

(define (get-date game)
  (car (cdr game)))

; Required libraries
(require net/url)
(require (prefix-in h: html) (prefix-in x: xml))

; Location to get data from
(define schedule-url "http://bruins.nhl.com/club/scheduleprint.htm?season=20102011&gameType=2&team=BOS")

; Some helpers
(define (get-html url)
  (h:read-html (get-pure-port (string->url url))))

(define (nth list count)
  (if (= count 1) 
      (car list)
      (nth (cdr list) (- count 1))))

; Base case is missing on purpose for debugging, and because I dont know how to throw exceptions, if they even exist
(define (first-match list predicate?)
  (if (empty? list)
      '()
      (if (predicate? (car list))
          (car list)
          (first-match (cdr list) predicate?))))

(define (string-contains string char)
  (if (equal? string "")
      #f
      (if (equal? (substring string 0 1) char)
          #t
          (string-contains (substring string 1) char))))

(define (string-starts string char)
  (equal? (substring string 0 1) char))

(define (get-pcdata td)
  (if (not (h:td? td))
      ""
      (first-match 
       (map (lambda (x) (x:pcdata-string x)) (filter (lambda (x) (and (not (eq? x 'nbsp)) (not (x:entity? x)))) (h:html-full-content td))) 
       (lambda (x) (not (string-contains x "\n"))))))

; Get our html
(define bruins-html (get-html schedule-url))

; Grab the elements we need
(define body (car (cdr (h:html-full-content bruins-html))))
(define hosting-div (first-match (h:html-full-content body) h:div?))
(define data-tables (filter (lambda (x) (h:table? x)) (h:html-full-content hosting-div)))

(define (get-rows table)
  (h:html-full-content
   (car
    (h:html-full-content table))))

(define (combine-rows tables)
  (if (empty? tables)
      '()
      (cons (get-rows (car tables)) (combine-rows (cdr tables)))))

(define (extract-rows rows)
  (if (empty? rows)
      '()
      (cons (process-row (car rows)) (extract-rows (cdr rows)))))

(define (get-cells row)
  (filter h:td?
          (h:html-full-content row)))

;(define (extract-cell cell)
;  (if (eqv? cell '())
;      ""
;      (x:pcdata-string
;       (car
;        (filter (lambda(x) (not
;                            (equal? 
;                             (x:pcdata-string x) "\n"))) (h:html-full-content cell))))))

(define extract-cell get-pcdata)

(define (process-row row)
  (let ((cells (get-cells row)))
    (make-game (extract-cell (nth cells 1)) (extract-cell (nth cells 2))
               (extract-cell (nth cells 3)) (extract-cell (nth cells 4))
               (extract-cell (nth cells 5)) (extract-cell (nth cells 6))
               (extract-cell (nth cells 7))
    )))

; Process rows
(define raw-rows (flatten (combine-rows data-tables)))
(define processed-rows (extract-rows raw-rows))
(define filtered-rows (filter (lambda (x) (not (equal? (get-date x) "Date"))) processed-rows))

; Define functions to process the data
(define (extract-games tables)
  (if (empty? tables)
      '()
      (cons (extract-rows (get-rows (car tables))) (extract-games (cdr tables)))))
       
; And now display the results
; (extract-games data-tables)
filtered-rows