#lang racket/gui
(require db/base
         db/sqlite3)
; dbxplorer
; a gui to explore and modify the contents of a sqlite database

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

(define menu-file-open (new menu-item%
                            [parent menu-file]
                            [label "&Open"]
                            [callback (λ (button event)
                                        (void))]))

(send frame show #t)
