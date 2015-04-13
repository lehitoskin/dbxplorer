#!/usr/bin/env racket
#lang racket/gui
; dbxplorer
; a gui to explore and modify the contents of a sqlite database
(require db/base
         db/sqlite3
         data/queue
         "queries.rkt")

; path to the database file
(define db-file (make-parameter #f))
; sql connection to be created later
(define sqlc (make-parameter #f))
; queue for actions to apply to an opened database
(define actions-queue (make-queue))

(define frame (new frame%
                   [label "dbxplorer"]
                   [height 600]
                   [width 800]
                   [stretchable-width #t]))

(define menu-bar (new menu-bar%
                      [parent frame]))

(define menu-file (new menu%
                       [parent menu-bar]
                       [label "&File"]))

(define menu-file-open
  (new menu-item%
       [parent menu-file]
       [label "&Open"]
       [shortcut #\O]
       [callback (λ (button event)
                   ; make sure we disconnect any sqlite connections we might already have
                   (unless (false? (db-file))
                     (disconnect (sqlc)))
                   (let ([path (get-file "Select a database"
                                         #f
                                         #f
                                         #f
                                         "sqlite"
                                         null
                                         '(("sqlite" "*.sqlite;*.sql;*.db")
                                           ("Any" "*.*")))])
                     (unless (false? path)
                       ; set the db-file to the file we selected
                       (db-file path)
                       (send file-opened set-label (path->string (last (explode-path path))))
                       ; create a new db connection
                       (sqlc (sqlite3-connect #:database (db-file))))))]))

(define menu-file-quit
  (new menu-item%
       [parent menu-file]
       [label "&Quit"]
       [shortcut #\Q]
       [callback (λ (button event)
                   ; if we aren't using a db-file, we can just exit
                   (cond [(false? (db-file)) (exit)]
                         ; otherwise we need to disconnect the sqlite connection
                         [else (disconnect (sqlc))
                               (exit)]))]))

(define file-opened (new message%
                         [parent frame]
                         [label "No database currently selected"]
                         [auto-resize #t]))

(define hpanel (new horizontal-panel%
                    [parent frame]))

(define actions-list
  (new list-box%
       [parent hpanel]
       [label #f]
       [choices '("Tables"
                  "Columns")]
       [callback (λ (l e)
                   (when (and (eq? (send e get-event-type) 'list-box-dclick)
                              (connection? (sqlc)))
                     (if (zero? (send l get-selection))
                         (for ([i (tables (sqlc))])
                           (send results-text insert (string-append i "\n")))
                         (send results-text insert
                               (string-append
                                (vector-ref (first (columns (sqlc))) 4) "\n")))))]))

; text object for the editor canvas
(define results-text (new text% [auto-wrap #t]))
; smaller, black font to work with for the editor canvas
(define black-style (make-object style-delta% 'change-size 10))
(send results-text change-style black-style)

(define results-ecanvas (new editor-canvas%
                             [parent hpanel]
                             [editor results-text]
                             [min-width 700]))

(define custom-query-tfield
  (new text-field%
       [parent frame]
       [label "Custom query "]
       [callback (λ (l e)
                   (when (and (eq? (send e get-event-type) 'text-field-enter)
                              (connection? (sqlc))
                              (not (string=? (send l get-value) "")))
                     (send results-text insert (query (sqlc) (send l get-value)))))]))

(send frame show #t)
