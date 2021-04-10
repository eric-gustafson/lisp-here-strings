;;;; package.lisp

(defpackage #:stringhere
  (:use #:cl)
  (:export :*previous-readtable*  :enable-txt-syntax :disable-txt-syntax
	   :slurp-file-as-code)
  )

