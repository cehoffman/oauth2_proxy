FROM scratch

COPY output /

ENTRYPOINT ["/oauth2_proxy"]
