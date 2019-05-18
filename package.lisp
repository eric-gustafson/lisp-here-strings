;;;; package.lisp

(defpackage #:stringhere
  (:use #:cl #:stefil)
  (:export :*previous-readtable*  :enable-txt-syntax :disable-txt-syntax
	   :slurp-file-as-code)
  )

