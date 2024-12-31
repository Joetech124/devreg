;; DevReg - Advanced Device Registration and Management System

;; Constants for error codes
(define-constant ERR_ALREADY_REGISTERED (err u100))
(define-constant ERR_NOT_FOUND (err u101))
(define-constant ERR_INVALID_INPUT (err u102))
(define-constant ERR_NOT_OWNER (err u103))
(define-constant ERR_TRANSFER_LIMIT (err u104))

;; Define a map to store device registration information
(define-map device-registry
  { device-id: (buff 32) }
  { owner: principal, registration-time: uint, transfer-count: uint })

;; Define a map to track devices owned by each user
(define-map user-devices
  { user: principal }
  { device-count: uint })

;; Define a map to store device metadata
(define-map device-metadata
  { device-id: (buff 32) }
  { name: (string-utf8 64), description: (string-utf8 256) })

;; Public function to register a new device with metadata
(define-public (register-device (device-id (buff 32)) (name (string-utf8 64)) (description (string-utf8 256)))
  (let ((caller tx-sender))
    (if (and 
          (<= (len device-id) u32)
          (<= (len name) u64)
          (<= (len description) u256))
        (match (map-get? device-registry { device-id: device-id })
          success ERR_ALREADY_REGISTERED
          (begin
            (map-set device-registry 
              { device-id: device-id } 
              { owner: caller, registration-time: block-height, transfer-count: u0 })
            (map-set device-metadata
              { device-id: device-id }
              { name: name, description: description })
            (map-set user-devices { user: caller } 
              { device-count: (+ u1 (default-to u0 (get device-count (map-get? user-devices { user: caller })))) })
            (ok true)))
        ERR_INVALID_INPUT)))

;; Public function to check if a device is registered
(define-read-only (is-device-registered (device-id (buff 32)))
  (is-some (map-get? device-registry { device-id: device-id })))

;; Public function to get the owner of a registered device
(define-read-only (get-device-owner (device-id (buff 32)))
  (match (map-get? device-registry { device-id: device-id })
    registration (ok (get owner registration))
    ERR_NOT_FOUND))

;; Public function to get device metadata
(define-read-only (get-device-metadata (device-id (buff 32)))
  (match (map-get? device-metadata { device-id: device-id })
    metadata (ok metadata)
    ERR_NOT_FOUND))

;; Public function to transfer device ownership with transfer limit
(define-public (transfer-device (device-id (buff 32)) (new-owner principal))
  (let 
    ((caller tx-sender)
     (transfer-limit u5))
    (match (map-get? device-registry { device-id: device-id })
      registration 
        (if (is-eq (get owner registration) caller)
            (if (< (get transfer-count registration) transfer-limit)
                (begin
                  (map-set device-registry { device-id: device-id } 
                    { owner: new-owner, 
                      registration-time: (get registration-time registration), 
                      transfer-count: (+ u1 (get transfer-count registration)) })
                  (map-set user-devices { user: caller } 
                    { device-count: (- (default-to u0 (get device-count (map-get? user-devices { user: caller }))) u1) })
                  (map-set user-devices { user: new-owner } 
                    { device-count: (+ u1 (default-to u0 (get device-count (map-get? user-devices { user: new-owner })))) })
                  (ok true))
                ERR_TRANSFER_LIMIT)
            ERR_NOT_OWNER)
      ERR_NOT_FOUND)))

;; Public function to update device metadata
(define-public (update-device-metadata (device-id (buff 32)) (name (string-utf8 64)) (description (string-utf8 256)))
  (let ((caller tx-sender))
    (match (map-get? device-registry { device-id: device-id })
      registration 
        (if (is-eq (get owner registration) caller)
            (begin
              (map-set device-metadata
                { device-id: device-id }
                { name: name, description: description })
              (ok true))
            ERR_NOT_OWNER)
      ERR_NOT_FOUND)))

;; Public function to get the number of devices registered by a user
(define-read-only (get-user-device-count (user principal))
  (ok (default-to u0 (get device-count (map-get? user-devices { user: user })))))

;; Public function to check if a user owns any devices
(define-read-only (user-has-devices (user principal))
  (> (default-to u0 (get device-count (map-get? user-devices { user: user }))) u0))