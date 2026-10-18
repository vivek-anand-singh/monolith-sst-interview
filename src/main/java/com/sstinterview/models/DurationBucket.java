package com.sstinterview.models;

/**
 * Round length as a bucket rather than a minute count — one tap for the author,
 * and no false precision on a number nobody actually measured.
 */
public enum DurationBucket
{
    UNDER_30, MIN_30_60, MIN_60_90, OVER_90
}
