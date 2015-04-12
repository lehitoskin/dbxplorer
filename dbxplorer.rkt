#lang racket/gui
; dbxplorer
; a gui to explore and modify the contents of a sqlite database

(define frame (new frame%
                   [label "dbxplorer"]
                   [height 600]
                   [width 800]))

(send frame show #t)
