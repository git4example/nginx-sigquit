FROM nginx:1.21.3
COPY new-entrypoint.sh /
STOPSIGNAL SIGTERM
ENTRYPOINT ["/new-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]