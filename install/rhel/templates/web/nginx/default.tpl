server {
    listen      %ip%:%proxy_port%;
    server_name %domain_idn% %alias_idn%;
    error_log  /var/log/httpd/domains/%domain%.error.log crit;

    location / {
        proxy_pass      http://%ip%:%web_p# ort%;
        location ~* ^.+\.(%proxy_extentions%)$ {
            root           %docroot%;
            # access_log     /var/log/httpd/domains/%domain%.log combined;
            # access_log     /var/log/httpd/domains/%domain%.bytes bytes;
            expires        max;
            try_files      $uri @fallback;
        }
    }

    location /error/ {
        alias   %home%/%user%/web/%domain%/document_errors/;
    }

    location @fallback {
        proxy_pass      http://%ip%:%web_port%;
    }

    location ~ /\.ht    {return 404;}
    location ~ /\.svn/  {return 404;}
    location ~ /\.git/  {return 404;}
    location ~ /\.hg/   {return 404;}
    location ~ /\.bzr/  {return 404;}

    # GZIP support
    gzip on;
    gzip_types text/css text/x-component application/x-javascript application/javascript text/javascript text/x-js text/richtext image/svg+xml text/plain text/xsd text/xsl text/xml image/x-icon;

    # ngx_pagespeed configuration (disabled by default; to enable it set pagespeed directive to on - only in production)
    # To purge the ngx_pagespeed cache run touch /var/ngx_pagespeed_cache/cache.flush
    pagespeed off;
    pagespeed FileCachePath /var/ngx_pagespeed_cache;

    # Ensure requests for pagespeed optimized resources go to the pagespeed handler and no extraneous headers get set
    location ~ "\.pagespeed\.([a-z]\.)?[a-z]{2}\.[^.]{10}\.[^.]+" {
      add_header "" "";
    }
    location ~ "^/pagespeed_static/" { }
    location ~ "^/ngx_pagespeed_beacon$" { }

    # Rewrite Level
    pagespeed RewriteLevel PassThrough;

    # Minimize and optimize HTTP requests
    pagespeed EnableFilters rewrite_css;
    pagespeed EnableFilters rewrite_javascript;
    pagespeed EnableFilters combine_css;
    pagespeed EnableFilters combine_javascript;
    pagespeed EnableFilters inline_css;
    pagespeed CssInlineMaxBytes 4096;
    pagespeed EnableFilters inline_javascript;
    pagespeed JsInlineMaxBytes 4096;

    # Image Optimization and lazy load
    pagespeed EnableFilters rewrite_images;
    pagespeed EnableFilters inline_images;
    pagespeed EnableFilters resize_images;
    pagespeed EnableFilters recompress_images;
    pagespeed EnableFilters convert_jpeg_to_webp;
    pagespeed ImageRecompressionQuality 85;
    pagespeed EnableFilters inline_preview_images;
    pagespeed EnableFilters lazyload_images;

    # Remove comments and minify HTML
    pagespeed EnableFilters remove_comments;
    pagespeed EnableFilters collapse_whitespace;

    # MaxCDN integration
    # pagespeed Domain *.netdna-cdn.com;

    include %home%/%user%/conf/web/nginx.%domain%.conf*;
}

