;Paul Senatillaka
;HTML Parser
;#lang racket

;This is a continuation of the html parsing library from FPE3 
;This code will take a list of URL's of class schedules, retrieve the html, and parse it to one big list of Schedule structs that we defined
;At the bottom of this code we then show how to filter to retrieve all the sections for a particular course

(require (prefix-in h: html)
         (prefix-in x: xml))
(require net/url)

;We're using a shorter list here for testing. THe full list takes a little while to startup
(define all-schedules-urls
  '("http://www.uml.edu/registrar/term_fall/SCHEDULE/LCOMPSCI.html"
    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LBIOLOGY.html"
    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LCHEMISTRY.html"
    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LENVIRNSCI.html"
    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LINFOTECH.html"
    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LMATH.html"
    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LPHYSICS.html"
    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LPOLYMSCI.html"
    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LRADSCI.html"))

;(define all-schedules-urls
;  '("http://www.uml.edu/registrar/term_fall/SCHEDULE/LCOMPSCI.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LAESTCRSTY.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LAMERSTDY.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LAPPLMUSIC.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LARTHISTRY.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LCRIMJUST.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LREGECOSOC.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LECONOMICS.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LENGLISH.html"
;    "http://www.uml.edu/registrar/term_fall/schedule/LGENDSTDY.HTML"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LHISTORY.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LARTSCI.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LCULTURSTD.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LLEGALSTDY.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LMUSICBUS.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LMUSICED.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LMUSICHIST.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LMUSICTHRY.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LMUSICTHRY.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LHUMSOCSC.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LMUSICPERF.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LPHILOSPHY.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LPOLISCI.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LPSYCHGY.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LSOCIOLOGY.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LSNDRECTEC.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LSTUDIOART.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LBIOLOGY.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LCHEMISTRY.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LENVIRNSCI.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LINFOTECH.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LMATH.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LPHYSICS.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LPOLYMSCI.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LRADSCI.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LCURR&INST.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LCHEMENGR.html"
;    "http://www.uml.edu/registrar/term_fall/schedule/LCEENVENGR.html"
;    "http://www.uml.edu/registrar/term_fall/schedule/LEECSENGR.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LEECSENGRTECH.html"
;    "http://www.uml.edu/registrar/term_fall/schedule/LENVIRONML.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LENGINEER.html"
;    "http://www.uml.edu/registrar/term_fall/schedule/lmechengr.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LMECHENGRTECH.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LNEENGENGR.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LPLSTCENGR.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LPLSTCENGRTECH.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LACCOUNT.html"
;    "http://www.uml.edu/registrar/term_fall/schedule/LENTREPREN.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LFINANCE.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LMGMTDEPT.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LOPERSYS.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LMARKETING.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LBIOENGTC.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LMARSCITC.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LCLILABSCI.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LMEDTECH.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LHEALTHED.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LHESRADMIN.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LEXPHYSGY.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LHEALTH.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LNURSING.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LPHYLTHRPY.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/LWRKENVIRN.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/UMLOWELLAERO.html"
;    "http://www.uml.edu/registrar/term_fall/SCHEDULE/UMLOWELLARMY.html"    
;    ))



;Data Structs
(struct Schedule-Entry (title coursenum classnum instructor perm status campus days starttime endtime credits capacity enrolled wait gened reqs))

;We have to traverse the HTML DOM a little to find the table that holds schedules
(define (schedule-table schedule)
  (cadr (filter h:table? (h:html-full-content (car(h:html-full-content(car(h:html-full-content(car(h:html-full-content (car (filter h:table? (h:html-full-content (cadr (h:html-full-content schedule)))))))))))))))





;Helpers
;---------------

;Gets just the cells <td> from a row
;Input: <#Row>
;Output List of <#Td>
(define (get-cells row)
  (filter h:td?
          (h:html-full-content row)))

;Gets html row objects from a table
;Filters out the first row of the schedule table as it is the column header. We are left with just data
;Input: <#Table>
;Output List of <#Rows>
(define (get-schedule-rows schedule)
  (list-tail (h:html-full-content (car (h:html-full-content (schedule-table schedule)))) 1))

;Parses a row <tr> into a Schedule-Entry struct object
;Input: <#Row>
;Output <#Schedule-Entry>
(define (parse-row row)
  (let ((cells (get-cells row)))
    (Schedule-Entry (get-pcdata (list-ref cells 0)) 
                    (get-pcdata (list-ref cells 1))
                    (get-pcdata (list-ref cells 2))
                    (get-pcdata (list-ref cells 3))
                    (get-pcdata (list-ref cells 4))
                    (get-pcdata (list-ref cells 5))
                    (get-pcdata (list-ref cells 6))
                    (get-pcdata (list-ref cells 7))
                    (get-pcdata (list-ref cells 8))
                    (get-pcdata (list-ref cells 9))
                    (get-pcdata (list-ref cells 10))
                    (get-pcdata (list-ref cells 11))
                    (get-pcdata (list-ref cells 12))
                    (get-pcdata (list-ref cells 13))
                    (get-pcdata (list-ref cells 14))
                    (get-pcdata (list-ref cells 15)))))

;Extracts the data from an element.  Does some clean up like excludes \n and invalid elements
;Input: <#Td>
;Output: #String
(define (get-pcdata td)
  (if (not (h:td? td))
      ""
      (first-match 
       (map (lambda (x) (x:pcdata-string x)) (filter (lambda (x) (and (not (eq? x 'nbsp)) (not (x:entity? x)) (not (h:br? x)))) (h:html-full-content td)))
       (lambda (x) (not (string-contains x "\n"))))))

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

;Cartesian Product of two lists
;This is used for creating all possible combinations of two lists
(define (cart xs ys)
  (let ((f (lambda (x) (map (lambda (y) (list x y)) ys))))
    (apply append (map f xs))))

(define (print-schedule schedule-list)
  (map (lambda (schedule-entry-row) 
         (map (lambda(schedule-entry) 
                (display (list 
                          (Schedule-Entry-title schedule-entry) (Schedule-Entry-classnum schedule-entry) (Schedule-Entry-days schedule-entry) (Schedule-Entry-starttime schedule-entry) (Schedule-Entry-endtime schedule-entry) " "))) schedule-entry-row))
  schedule-list))

;End of Helper Funcs
;------------------


;Worker Functions
;------------------

;Function that Parses and creates list of #<Schedule-Entry>'s from a list of all schedule URLs
(define (process-all-schedules all-schedules-urls)
  ;Get list of custom <#Schedule-Entry> objects from each row
  (map (lambda (schedule-row) (parse-row schedule-row))
       (flatten 
        ;Get list of of <#Row> Objects from each <#HTML> Object
        (map (lambda (schedule-html) (get-schedule-rows schedule-html))
             ;Get list of <#HTML> Objects from list of Page URL's
             (map (lambda (schedule-url) (h:read-html (get-pure-port (string->url schedule-url))))
                  all-schedules-urls)))))


;Creates a list of possible class schedules. Each entry is a sublist for each section of a class offered.
;Input: List of Course Number #Strings, List of <#Schedule-Entry> (This would be the full schedule offered)
;Output List of Lists of filtered down <#Schedule-Entry>'s
(define (filter-classes classes all-schedules)
  (if (empty? classes)
      '()
      (cons (filter (lambda (entry) (regexp-match? (car classes) (Schedule-Entry-coursenum entry))) (process-all-schedules all-schedules-urls))
            (filter-classes (cdr classes) all-schedules))))



;Create the list of class schedule permutations from the list of class schedules that contain all the sections
;Input: List of Lists of <#Schedule-Entry>'s
;Output: List of Lists of <#Schedule-Entry>'s
(define (permutate-schedule filtered-schedule)
  (if (empty? filtered-schedule)
      '()
      (map flatten 
           (helper-permutate (cdr filtered-schedule) (car filtered-schedule)))))

;We recursively call the cartesian product on each schedule element and the result
(define (helper-permutate partial-list result)
  (if (empty? partial-list)
      result
      (helper-permutate (cdr partial-list) (cart result (car partial-list)))))




;Testing Data
;(define all-schedules
;  (process-all-schedules all-schedules-urls))
;(define class-schedule 
;  (permutate-schedule (filter-classes '("91.101" "91.113") all-schedules)))
;
;(print-schedule class-schedule)

;(define courselist
;  (map (lambda(x)(Schedule-Entry-coursenum x)) all-schedules))

