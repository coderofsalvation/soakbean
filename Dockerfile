# syntax=docker/dockerfile:1
FROM scratch
ADD soakbean.com /

CMD ["/soakbean.com"]
