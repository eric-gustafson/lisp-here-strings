;;;; stringhere.lisp

(in-package #:stringhere)

(defparameter *previous-readtable* '())

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun txt-reader (stream sub-char numarg)
  "a function that is registered with the lisp reader"
  (declare (ignore sub-char numarg))
  (let ((level 1) ;; We enter this function with this character already read in
	(buff (make-string-output-stream))
	(sexp-lst '())
	)
    (loop
       (let ((c (read-char stream nil nil)))
	 ;;(format t "~a:~a~%" c level)
	 (let ((pa (if (characterp c)
		       (peek-char nil stream nil nil))))
	   (cond
	     ((and (eq c #\,)
		   (eq pa #\())
	      ;;(read-char stream nil nil)
	      (let ((obj  (read stream t nil t)))
		;; Push the collected string onto the sexp list, and it also
		;; resets the buffer (2 for 1)
		(push `(princ ,(get-output-stream-string buff)) sexp-lst)
		;; Use the read function to get lisp code.
		(push obj sexp-lst)))
	     (t
	      (when (eq c #\{) (incf level))
	      (when (eq c #\}) (decf level))
	      (cond
		((or (eq c nil)
		     (<= level 0))
		 (push `(princ ,(get-output-stream-string buff)) sexp-lst)		 
		 (return `(progn ,@(reverse sexp-lst))
			 )
		 )
		(t
		 (write-char c buff))
		)
	      )
	     )
	   )
	 ))
    )
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;#{\item{hi ,(format t "a")}  }
;;#{\item{hi}}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun top-level-read (stream)
  "Used to read in a file that has the templating system defined by the stringhere macro"
  (let ((level 1)
	(buff (make-string-output-stream))
	(sexp-lst '())
	)
    (loop
       (let ((c (read-char stream nil nil)))
	 (let ((pa (if (characterp c)
		       (peek-char nil stream nil nil)
		       nil)))
	   ;;(print pa)
	   (cond
	     ((and (eq c #\,)
		   (eq pa #\())
	      ;;(read-char stream nil nil)
	      (princ (get-dispatch-macro-character #\# #\{))
	      (let ((obj  (read stream t nil)))
		;; Push the collected string onto the sexp list, and it also
		;; resets the buffer (2 for 1)
		(push `(princ ,(get-output-stream-string buff)) sexp-lst)
		;; Use the read function to get lisp code.
		(push obj sexp-lst)))
	     (t
	      (when (eq c #\{) (incf level))
	      (when (eq c #\}) (decf level))
	      (cond
		((or (eq c nil)
		     (and (<= level 0)
			  (eq c #\} )))
		 (push `(princ ,(get-output-stream-string buff)) sexp-lst)		 
		 (return `(progn ,@(reverse sexp-lst))
			 )
		 )
		(t
		 (write-char c buff))
		)
	      )
	     )
	   )
	 )
       )
    )
  )

(defun slurp-file-as-code (path)
  "read the file as a here string.  This will create a (progn ...) snipped of code"
  (with-open-file (stream path :direction :input)
    ;;Create a string stream that will put read into loaded stat in order to read
    ;; a file from the stream with the here functionality already triggered.
    (top-level-read stream)
    )
		    
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	   
;; (defun create-c-function (return name &rest args)
;;   (format *standard-output* "~a ~a (~{~a~^, ~})   " return name args)
;;   #{
;;   {
;;   #define __JUST_A_TEST__
;;   // ,(princ name)
;;   #endif
;;   }
;;   })


;;; "stringhere" goes here. Hacks and glory await!
(defmacro enable-txt-syntax ()
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (push *readtable* stringhere:*previous-readtable*)
     (setq *readtable* (copy-readtable))
     ;;(set-macro-character #\} 'read-separator)
     (set-dispatch-macro-character #\# #\{ #'stringhere::txt-reader)
     )
  )

(defun disable-txt-syntax ()
  (eval-when (:compile-toplevel :load-toplevel :execute)
    (setq *readtable* (pop stringhere:*previous-readtable*))
    )
  )

(defun reset ()
  (disable-txt-syntax)
  (enable-txt-syntax)
  )

