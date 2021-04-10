;;;; stringhere.asd

(asdf:defsystem #:stringhere
  :description "A reader macro for common lisp that generates text.
  It's like a here-string in perl, bash, python but better because
  lisp figured out how to do things decades ago (everything that sucks
  about this library is my fault alone)."
  :author "Your Name <goofofferson@gmail.com>"
  :license "BSD"
  :serial t
  :depends-on ()
  :components ((:file "package")
               (:file "stringhere")))

