package com.sstinterview.exception;

public class GoogleTokenVerificationException extends RuntimeException {
    public GoogleTokenVerificationException(String message, Throwable cause) {
        super(message, cause);
    }
}
