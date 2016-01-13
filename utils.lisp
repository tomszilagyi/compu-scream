(require :screamer)
(in-package :screamer-user)

(defun update-plist (plist indicator new-value)
  (let ((other-properties nil))
    (loop while plist
          for property = (pop plist)
          for value = (pop plist)
          when (eq property indicator)
          do (return-from update-plist (list* property new-value
                                              (append other-properties plist)))
          else do (push value other-properties)
          (push property other-properties))
    (list* indicator new-value other-properties)))


(defun slice-string-inner (string length slice-length slice-list)
  (if (> length slice-length)
      (let* ((rem-length (- length slice-length))
             (rem-string (subseq string 0 rem-length))
             (slice (subseq string rem-length length)))
        (slice-string-inner rem-string rem-length slice-length (cons slice slice-list)))
      (cons string slice-list)))

(defun slice-string (string slice-length sep-char)
  (if (> slice-length 0)
      (let ((slice-list (slice-string-inner string (length string) slice-length nil))
            (format-str (format nil "~~{~~A~~^~c~~}" sep-char)))
        (format nil format-str slice-list))
      string))

(deftest-fun-args test-slice-string-t1 slice-string ("123456" 0 #\_) "123456")
(deftest-fun-args test-slice-string-t2 slice-string ("10" 4 #\_) "10")
(deftest-fun-args test-slice-string-t3 slice-string ("1100" 4 #\_) "1100")
(deftest-fun-args test-slice-string-t4 slice-string ("1011001100" 4 #\_) "10_1100_1100")
(deftest-fun-args test-slice-string-t5 slice-string ("abcdefghgijklmnop" 8 #\:) "a:bcdefghg:ijklmnop")

(deftest test-slice-string ()
  (combine-results
   (test-slice-string-t1)
   (test-slice-string-t2)
   (test-slice-string-t3)
   (test-slice-string-t4)
   (test-slice-string-t5)))


(defun vector->value-int (v val)
  (if (null v)
      val
      (let ((d (car v))
            (r (cdr v)))
        (if d
            (vector->value-int r (1+ (* 2 val)))
            (vector->value-int r (* 2 val))))))

(defun vector->value (v)
  (vector->value-int (mapcar #'value-of v) 0))

(defun vector->binstr (v &key (slice 4) (sep #\_))
  (let ((str (make-array (length v)
                         :element-type 'character
                         :initial-contents (mapcar #'(lambda (b) (if b #\1 #\0)) v))))
    (slice-string str slice sep)))

(defun vector->hexstr (v  &key (slice 8) (sep #\:))
  (let ((str (format nil "~x" (vector->value v))))
    (slice-string str slice sep)))

(defun value->binstr (value bits &key (slice 4) (sep #\_))
  (slice-string (format nil "~v,'0b" bits value) slice sep))
(defun value->hexstr (value bits &key (slice 8) (sep #\:))
  (slice-string (format nil "~v,'0x" (/ bits 4) value) slice sep))

(deftest-fun-args test-vecval-t1 vector->value ('()) 0)
(deftest-fun-args test-vecval-t2 vector->value ('(nil)) 0)
(deftest-fun-args test-vecval-t3 vector->value ('(nil nil)) 0)
(deftest-fun-args test-vecval-t4 vector->value ('(t)) 1)
(deftest-fun-args test-vecval-t5 vector->value ('(nil t)) 1)
(deftest-fun-args test-vecval-t6 vector->value ('(t nil)) 2)
(deftest-fun-args test-vecval-t7 vector->value ('(t t)) 3)

(deftest-fun-args test-vecbin-t1 vector->binstr ('(nil t t nil)) "0110")
(deftest-fun-args test-vecbin-t2 vector->binstr ('(t nil t t nil)) "1_0110")
(deftest-fun-args test-vecbin-t3 vector->binstr ('(nil nil)) "00")
(deftest-fun-args test-vecbin-t4 vector->binstr ('(nil nil t t t t)) "00_1111")
(deftest-fun-args test-vecbin-t5
  vector->binstr ('(t nil t nil t nil t nil t t t t nil nil nil nil t t t t t nil))
  "10_1010_1011_1100_0011_1110")
(deftest-fun-args test-vecbin-t6
  vector->binstr ('(t nil t nil t nil t nil t t t t nil nil nil nil t t t t t nil)
                  :slice 0)
  "1010101011110000111110")

(deftest-fun-args test-vechex-t1 vector->hexstr ('(t nil t nil)) "A")
(deftest-fun-args test-vechex-t2 vector->hexstr ('(t t nil t)) "D")
(deftest-fun-args test-vechex-t3 vector->hexstr ('(t t t t t t)) "3F")
(deftest-fun-args test-vechex-t4 vector->hexstr ('(t t nil nil t)) "19")
(deftest-fun-args test-vechex-t5
  vector->hexstr ('(t nil t nil t nil t nil t t t t nil nil nil nil t t t t t t
                      t t t t nil t nil t t t t nil nil nil t t t t t nil))
  "2AB:C3FF5E3E")
(deftest-fun-args test-vechex-t6
  vector->hexstr ('(t nil t nil t nil t nil t t t t nil nil nil nil t t t t t t
                      t t t t nil t nil t t t t nil nil nil t t t t t nil)
                  :sep #\-)
  "2AB-C3FF5E3E")

(deftest-fun-args test-valbin-t1 value->binstr (24 8) "0001_1000")
(deftest-fun-args test-valbin-t2 value->binstr (124 16) "0000_0000_0111_1100")
(deftest-fun-args test-valbin-t3
  value->binstr (191634543 32) "0000_1011_0110_1100_0001_1100_0110_1111")
(deftest-fun-args test-valbin-t4
  value->binstr (191634543 32 :slice 8 :sep #\:) "00001011:01101100:00011100:01101111")

(deftest-fun-args test-valhex-t1 value->hexstr (1696 16) "06A0")
(deftest-fun-args test-valhex-t2 value->hexstr (4239987432 32) "FCB912E8")
(deftest-fun-args test-valhex-t3
  value->hexstr ((* 12345 12345 12345 12345) 64) "0052836F:752FD261")
(deftest-fun-args test-valhex-t4
  value->hexstr ((* 12345 12345 12345 12345) 64 :slice 0) "0052836F752FD261")

(deftest test-vecval ()
  (combine-results
   (test-vecval-t1)
   (test-vecval-t2)
   (test-vecval-t3)
   (test-vecval-t4)
   (test-vecval-t5)
   (test-vecval-t6)
   (test-vecval-t7)))

(deftest test-vecbin ()
  (combine-results
   (test-vecbin-t1)
   (test-vecbin-t2)
   (test-vecbin-t3)
   (test-vecbin-t4)
   (test-vecbin-t5)
   (test-vecbin-t6)))

(deftest test-vechex ()
  (combine-results
   (test-vechex-t1)
   (test-vechex-t2)
   (test-vechex-t3)
   (test-vechex-t4)
   (test-vechex-t5)
   (test-vechex-t6)))

(deftest test-valstr ()
  (combine-results
   (test-valbin-t1)
   (test-valbin-t2)
   (test-valbin-t3)
   (test-valbin-t4)
   (test-valhex-t1)
   (test-valhex-t2)
   (test-valhex-t3)
   (test-valhex-t4)))

;; ADD a and b on width w
(defun add (a b w)
  (logand (+ a b)
          (1- (ash 1 w))))

(deftest-fun-args test-add-t1 add (14 1 4) 15)
(deftest-fun-args test-add-t2 add (14 2 4) 0)
(deftest-fun-args test-add-t3 add (254 1 8) 255)
(deftest-fun-args test-add-t4 add (254 2 8) 0)

(deftest test-add ()
  (combine-results
   (test-add-t1)
   (test-add-t2)
   (test-add-t3)
   (test-add-t4)))

;; ROTL and ROTR given amount of bits on x of width w
(defun rotl (x w bits)
  (logior (logand (ash x (mod bits w))
                  (1- (ash 1 w)))
          (logand (ash x (- (- w (mod bits w))))
                  (1- (ash 1 w)))))

(defun rotr (x w bits)
  (logior (logand (ash x (- (mod bits w)))
                  (1- (ash 1 w)))
          (logand (ash x (- w (mod bits w)))
                  (1- (ash 1 w)))))

(deftest-fun-args test-rotl-t1 rotl (3 4 1) 6)
(deftest-fun-args test-rotl-t2 rotl (3 4 2) 12)
(deftest-fun-args test-rotl-t3 rotl (3 4 3) 9)
(deftest-fun-args test-rotl-t4 rotl (3 4 4) 3)
(deftest-fun-args test-rotr-t1 rotr (123 8 1) 189)
(deftest-fun-args test-rotr-t2 rotr (123 8 2) 222)
(deftest-fun-args test-rotr-t3 rotr (123 8 3) 111)
(deftest-fun-args test-rotr-t4 rotr (123 8 4) 183)

(deftest test-rot ()
  (combine-results
   (test-rotl-t1)
   (test-rotl-t2)
   (test-rotl-t3)
   (test-rotl-t4)
   (test-rotr-t1)
   (test-rotr-t2)
   (test-rotr-t3)
   (test-rotr-t4)))

;; SHL and SHR given amount of bits on x of width w
(defun shl (x w bits)
  (logand (ash x bits)
          (1- (ash 1 w))))

(defun shr (x w bits)
  (shl x w (- bits)))

(deftest-fun-args test-shl-t1 shl (3 4 1) 6)
(deftest-fun-args test-shl-t2 shl (3 4 2) 12)
(deftest-fun-args test-shl-t3 shl (3 4 3) 8)
(deftest-fun-args test-shl-t4 shl (3 4 4) 0)
(deftest-fun-args test-shr-t1 shr (123 8 1) 61)
(deftest-fun-args test-shr-t2 shr (123 8 2) 30)
(deftest-fun-args test-shr-t3 shr (123 8 3) 15)
(deftest-fun-args test-shr-t4 shr (123 8 4) 7)

(deftest test-shift ()
  (combine-results
   (test-shl-t1)
   (test-shl-t2)
   (test-shl-t3)
   (test-shl-t4)
   (test-shr-t1)
   (test-shr-t2)
   (test-shr-t3)
   (test-shr-t4)))


(deftest test-utils ()
  (combine-results
   (test-slice-string)
   (test-vecval)
   (test-vecbin)
   (test-vechex)
   (test-valstr)
   (test-add)
   (test-rot)
   (test-shift)))
