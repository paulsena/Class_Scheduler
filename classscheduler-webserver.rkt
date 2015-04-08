;Paul Senatillaka
;WebServer
#lang web-server/insta

(require racket/include)
(require racket/date)
(include "ClassScheduler-parser.rkt")

(static-files-path "htdocs")

(define all-schedules
  (process-all-schedules all-schedules-urls))
(define all-schedules-count (length all-schedules))
(define all-schedules-date (current-date))
;****** START

; Consumes a request, and produces a page that displays all of the
; web content.
(define (start request)
  (local [(define class-schedule (permutate-schedule (filter-classes (parse-form-input (request-bindings request)) all-schedules)))]
    (render-main-page class-schedule request)))

;Builds list of classes user wants to take
(define (parse-form-input bindings)
  (filter (lambda (listitem) (not(eq? (string-length listitem) 0)))
          (list (if (exists-binding? 'course1 bindings) (extract-binding/single 'course1 bindings) "")
                (if (exists-binding? 'course2 bindings) (extract-binding/single 'course2 bindings) "")
                (if (exists-binding? 'course3 bindings) (extract-binding/single 'course3 bindings) "")
                (if (exists-binding? 'course4 bindings) (extract-binding/single 'course4 bindings) "")
                (if (exists-binding? 'course5 bindings) (extract-binding/single 'course5 bindings) "")
                (if (exists-binding? 'course6 bindings) (extract-binding/single 'course6 bindings) ""))))

;Renders the main page
(define (render-main-page schedules request)
  (response/xexpr
   `(html (head (title "UML Class Scheduler")
                (link ((rel "stylesheet")
                       (href "/style.css")
                       (type "text/css")))
                (script ((src "/autocomplete.js")
                         (type "text/javascript")
                         (charset "utf-8")) ""))
          (body ((onLoad "createAutoComplete();"))
                (h1 "UML Class Scheduler")
                ,(render-schedules schedules)(br)
                (form (label "Enter Desired Course Numbers:")(br)
                      (input ((id "c1")(name "course1")(autocomplete "off")))(br)
                      (input ((id "c2")(name "course2")(autocomplete "off")))(br)
                      (input ((id "c3")(name "course3")(autocomplete "off")))(br)
                      (input ((id "c4")(name "course4")(autocomplete "off")))(br)
                      (input ((id "c5")(name "course5")(autocomplete "off")))(br)
                      (input ((id "c6")(name "course6")(autocomplete "off")))
                      (div ((id "suggest") (style "visibility:hidden;border:#000000 1px solid;")) "")
                      (input ((type "submit")))(br)(br)
                      (footer 
                       , (string-append (number->string all-schedules-count) " Classes Indexed @ " (date->string all-schedules-date all-schedules-date) )))))))

;Renders all the schedules. We use map to render each possible schedule
(define (render-schedules schedules)
  `(div ,@(map render-schedule schedules)))

;Renders one schedule. This uses the map function to render each entry of the schedule
(define (render-schedule schedule)
  `(br (table ((border "1"))
              (thead (tr (th "Course Title:" (th "Course Number:" (th "Class Number:" (th "Instructor:" (th "Perm:" (th "Status:" (th "Campus:" (th "Days:" (th "Start Time:" (th "End Time:" (th "Crdt Hrs:" (th "Max Cap" (th "Enrll:" (th "Wait Total:" (th "Gen Ed:" (th "Reqs and Co-reqs:"))))))))))))))))))
              (tbody
               ,@(map render-schedule-entry schedule )))))

;Renders one entry of a schedule
(define (render-schedule-entry schedule-entry)
  `(tr (td ,(Schedule-Entry-title schedule-entry))
       (td ,(Schedule-Entry-coursenum schedule-entry))
       (td ,(Schedule-Entry-classnum schedule-entry))
       (td ,(Schedule-Entry-instructor schedule-entry))
       (td ,(Schedule-Entry-perm schedule-entry))
       (td ,(Schedule-Entry-status schedule-entry))
       (td ,(Schedule-Entry-campus schedule-entry))
       (td ,(Schedule-Entry-days schedule-entry))
       (td ,(Schedule-Entry-starttime schedule-entry))
       (td ,(Schedule-Entry-endtime schedule-entry))
       (td ,(Schedule-Entry-credits schedule-entry))
       (td ,(Schedule-Entry-capacity schedule-entry))
       (td ,(Schedule-Entry-enrolled schedule-entry))
       (td ,(Schedule-Entry-wait schedule-entry))
       (td ,(Schedule-Entry-gened schedule-entry))
       (td ,(Schedule-Entry-reqs schedule-entry))))




