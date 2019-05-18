;;;; stringhere.asd

(asdf:defsystem #:stringhere
  :description "Describe stringhere here"
  :author "Your Name <your.name@example.com>"
  :license "Specify license here"
  :serial t
  :depends-on (#:stefil)
  :components ((:file "package")
               (:file "stringhere")))

