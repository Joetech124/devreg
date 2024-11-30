;; DevReg - Device Registration Tracker

;; Define a map to store device registration information
(define-map device-registry
  {device-id: (buff 32)}  ;; Key: Device ID
  {owner: (buff 40)})     ;; Value: Owner name

;; Public function to register a new device
(define-public (register-device (device-id (buff 32)) (owner (buff 40)))
  (if (and (<= (len device-id) u32) (<= (len owner) u40))
      (if (is-some (map-get? device-registry {device-id: device-id}))
          ;; If the device ID is already registered, return an error
          (err u100)
          ;; Otherwise, register the new device
          (ok (map-insert device-registry {device-id: device-id} {owner: owner})))
      ;; If inputs are invalid, return an error
      (err u102)))

;; Public function to check if a device is registered
(define-public (is-device-registered (device-id (buff 32)))
  (ok (is-some (map-get? device-registry {device-id: device-id}))))

;; Public function to get the owner of a registered device
(define-public (get-device-owner (device-id (buff 32)))
  (match (map-get? device-registry {device-id: device-id})
    some-owner (ok (get owner some-owner))  ;; Return the owner's name if found
    (err u101)))                            ;; Return an error if not found
