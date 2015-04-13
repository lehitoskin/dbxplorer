#lang racket/base
; queries.rkt
; contains predefined sqlite queries
(require db/base
         db/sqlite3)
(provide (all-defined-out))

(define (tables sqlc)
  (query-list sqlc "select name from sqlite_master where type='table';"))

(define (columns sqlc)
  (query-rows sqlc "select * from sqlite_master;"))
