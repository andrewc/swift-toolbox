//
//  WebHTTP.swift
//  Gane
//
//  Created by Andrew Christiansen on 5/12/16.
//  Copyright © 2016 SimplyTapp. All rights reserved.
//

import Foundation

public enum HTTPRequestMethod : String {
    case Get = "GET";
    case Post  = "POST";
    case Put = "PUT";
    case Head = "HEAD";
}

public enum HTTPStatusCodeClass : Int {
    case Informational = 1;
    case Success = 2;
    case Redirection = 3;
    case ClientError = 4;
    case ServerError = 5;

    public init?(statusCode: Int) {
        self.init(rawValue: Int(statusCode.description.substringToIndex(statusCode.description.startIndex.advancedBy(1)))!);
    }
}

public enum HTTPRequestHeader : String {
    case Accept = "Accept";
    case AcceptCharset = "Accept-Charset";
    case AcceptEncoding = "Accept-Encoding";
    case AcceptLanguage = "Accept-Language";
    case AcceptDatetime = "Accept-Datetime";
    case Authorization = "Authorization";
    case CacheControl = "Cache-Control";
    case Connection = "Connection";
    case Cookie = "Cookie";
    case ContentLength = "Content-Length";
    case ContentMD5 = "Content-MD5";
    case ContentType = "Content-Type";
    case Date = "Date";
    case Expect = "Expect";
    case Forwarded = "Forwarded";
    case From = "From";
    case Host = "Host";
    case IfMatch = "If-Match";
    case IfModifiedSince = "If-Modified-Since";
    case IfNoneMatch = "If-None-Match";
    case IfRange = "If-Range";
    case IfUnmodifiedSince = "If-Unmodified-Since";
    case MaxForwards = "Max-Forwards";
    case Origin = "Origin";
    case Pragma = "Pragma";
    case ProxyAuthorization = "Proxy-Authorization";
    case Range = "Range";
    case Referer  = "Referer";
    case TE = "TE";
    case UserAgent = "User-Agent";
    case Upgrade = "Upgrade";
    case Via = "Via";
    case Warning = "Warning";
}

public enum HTTPResponseHeader : String {
    case AccessControlAllowOrigin = "Access-Control-Allow-Origin";
    case AcceptPatc = "Accept-Patc";
    case AcceptRanges = "Accept-Ranges";
    case Age = "Age";
    case Allow = "Allow";
    case AltSv = "Alt-Sv";
    case CacheControl = "Cache-Control";
    case Connection = "Connection";
    case ContentDisposition = "Content-Disposition";
    case ContentEncoding = "Content-Encoding";
    case ContentLanguage = "Content-Language";
    case ContentLength = "Content-Length";
    case ContentLocation = "Content-Location";
    case ContentMD5 = "Content-MD5";
    case ContentRange = "Content-Range";
    case ContentType = "Content-Type";
    case Date = "Date";
    case ETag = "ETag";
    case Expires = "Expires";
    case LastModified = "Last-Modified";
    case Link = "Link";
    case Location = "Location";
    case P3P = "P3P";
    case Pragma = "Pragma";
    case ProxyAuthenticate = "Proxy-Authenticate";
    case PublicKeyPin = "Public-Key-Pin";
    case Refresh = "Refresh";
    case RetryAfter = "Retry-After";
    case Server = "Server";
    case SetCookie = "Set-Cookie";
    case Status = "Status";
    case StrictTransportSecurity = "Strict-Transport-Security";
    case Trailer = "Trailer";
    case TransferEncoding = "Transfer-Encoding";
    case TSV = "TSV";
    case Upgrade = "Upgrade";
    case Vary = "Vary";
    case Via = "Via";
    case Warning = "Warning";
    case WWWAuthenticate = "WWW-Authenticate";
}