(require :screamer)
(in-package :screamer-user)

(defun nibble-vector->hexchar (n)
  (cond ((equal n '(            nil)) #\0)
        ((equal n '(              t)) #\1)

        ((equal n '(        nil nil)) #\0)
        ((equal n '(        nil   t)) #\1)
        ((equal n '(          t nil)) #\2)
        ((equal n '(          t   t)) #\3)

        ((equal n '(    nil nil nil)) #\0)
        ((equal n '(    nil nil   t)) #\1)
        ((equal n '(    nil   t nil)) #\2)
        ((equal n '(    nil   t   t)) #\3)
        ((equal n '(      t nil nil)) #\4)
        ((equal n '(      t nil   t)) #\5)
        ((equal n '(      t   t nil)) #\6)
        ((equal n '(      t   t   t)) #\7)

        ((equal n '(nil nil nil nil)) #\0)
        ((equal n '(nil nil nil   t)) #\1)
        ((equal n '(nil nil   t nil)) #\2)
        ((equal n '(nil nil   t   t)) #\3)
        ((equal n '(nil   t nil nil)) #\4)
        ((equal n '(nil   t nil   t)) #\5)
        ((equal n '(nil   t   t nil)) #\6)
        ((equal n '(nil   t   t   t)) #\7)
        ((equal n '(  t nil nil nil)) #\8)
        ((equal n '(  t nil nil   t)) #\9)
        ((equal n '(  t nil   t nil)) #\A)
        ((equal n '(  t nil   t   t)) #\B)
        ((equal n '(  t   t nil nil)) #\C)
        ((equal n '(  t   t nil   t)) #\D)
        ((equal n '(  t   t   t nil)) #\E)
        ((equal n '(  t   t   t   t)) #\F)

        (t                            #\?)))

(defun nibble-hexchar->binstr (c)
  (cond ((eq c #\0) "0000")
        ((eq c #\1) "0001")
        ((eq c #\2) "0010")
        ((eq c #\3) "0011")
        ((eq c #\4) "0100")
        ((eq c #\5) "0101")
        ((eq c #\6) "0110")
        ((eq c #\7) "0111")
        ((eq c #\8) "1000")
        ((eq c #\9) "1001")
        ((eq c #\a) "1010")
        ((eq c #\b) "1011")
        ((eq c #\c) "1100")
        ((eq c #\d) "1101")
        ((eq c #\e) "1110")
        ((eq c #\f) "1111")
        (t          "xxxx")))