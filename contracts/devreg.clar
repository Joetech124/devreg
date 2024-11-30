;; DevReg - is a Device Registration Tracker

;; Constants for error codes
(define-constant ERR-ALREADY-REGISTERED u100)
(define-constant ERR-NOT-FOUND u101)
(define-constant ERR-INVALID-INPUT u102)
(define-constant ERR-NOT-OWNER u103)

;; Define a map to store device registration information
(define-map device-registry
  {device-id: (buff 32)}  ;; Key: Device ID
  {owner: principal})     ;; Value: Owner principal

;; Define a map to track devices owned by each user
(define-map user-devices
  {user: principal}
  {device-count: uint})

;; Public function to register a new device
(define-public (register-device (device-id (buff 32)))
  (let ((caller tx-sender))
    (if (<= (len device-id) u32)
        (if (is-some (map-get? device-registry {device-id: device-id}))
            (err ERR-ALREADY-REGISTERED)
            (begin
              (map-set device-registry {device-id: device-id} {owner: caller})
              (map-set user-devices {user: caller} 
                {device-count: (+ u1 (default-to u0 (get device-count (map-get? user-devices {user: caller}))))})
              (ok true)))
        (err ERR-INVALID-INPUT))))

;; Public function to check if a device is registered
(define-public (is-device-registered (device-id (buff 32)))
  (ok (is-some (map-get? device-registry {device-id: device-id}))))

;; Public function to get the owner of a registered device
(define-public (get-device-owner (device-id (buff 32)))
  (match (map-get? device-registry {device-id: device-id})
    registration (ok (get owner registration))
    (err ERR-NOT-FOUND)))

;; Public function to transfer device ownership
(define-public (transfer-device (device-id (buff 32)) (new-owner principal))
  (let 
    (
      (caller tx-sender)
      (current-owner-devices (get device-count (default-to {device-count: u0} (map-get? user-devices {user: caller}))))
    )
    (if (and 
          (<= (len device-id) u32) 
          (is-some (map-get? device-registry {device-id: device-id}))
          (not (is-eq new-owner caller))
        )
        (match (map-get? device-registry {device-id: device-id})
          registration 
            (if (is-eq (get owner registration) caller)
                (begin
                  (map-set device-registry {device-id: device-id} {owner: new-owner})
                  (map-set user-devices {user: caller} 
                    {device-count: (- current-owner-devices u1)})
                  (map-set user-devices {user: new-owner} 
                    {device-count: (+ u1 (default-to u0 (get device-count (map-get? user-devices {user: new-owner}))))})
                  (ok true))
                (err ERR-NOT-OWNER))
          (err ERR-NOT-FOUND))
        (err ERR-INVALID-INPUT))))

;; Public function to deregister a device
(define-public (deregister-device (device-id (buff 32)))
  (let ((caller tx-sender))
    (if (<= (len device-id) u32)
        (match (map-get? device-registry {device-id: device-id})
          registration 
            (if (is-eq (get owner registration) caller)
                (begin
                  (map-delete device-registry {device-id: device-id})
                  (map-set user-devices {user: caller} 
                    {device-count: (- (default-to u0 (get device-count (map-get? user-devices {user: caller}))) u1)})
                  (ok true))
                (err ERR-NOT-OWNER))
          (err ERR-NOT-FOUND))
        (err ERR-INVALID-INPUT))))

;; Public function to get the number of devices registered by a user
(define-public (get-user-device-count (user principal))
  (ok (default-to u0 (get device-count (map-get? user-devices {user: user})))))

;; Public function to check if a user owns any devices
(define-public (user-has-devices (user principal))
  (ok (> (default-to u0 (get device-count (map-get? user-devices {user: user}))) u0)))

