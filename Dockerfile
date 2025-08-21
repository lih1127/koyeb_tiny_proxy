# Stage 1: Build the application from source
FROM debian:bullseye-slim AS builder

# 1. Install build dependencies and dos2unix utility
RUN apt-get update && apt-get install -y build-essential automake autoconf dos2unix

# 2. Copy the application source code
WORKDIR /app
COPY . .

# 3. Fix line endings in shell scripts AND the VERSION file
RUN find . -name "*.sh" -exec dos2unix {} \; && find . -name "*.sh" -exec chmod +x {} \;
RUN dos2unix VERSION

# 4. Run the build process step-by-step
RUN ./autogen.sh
RUN ./configure --prefix=/usr/local --sysconfdir=/etc
RUN make
RUN make install


# Stage 2: Create the final, minimal image for execution
FROM debian:bullseye-slim

# 1. Install only necessary runtime dependencies (ca-certificates is good practice)
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

# 2. Copy the compiled binary and default config from the builder stage
COPY --from=builder /usr/local/bin/tinyproxy /usr/local/bin/tinyproxy
COPY --from=builder /etc/tinyproxy.conf /etc/tinyproxy/tinyproxy.conf

# 3. Create a non-root user and group to run the application for security
RUN groupadd --system tinyproxy && \
    useradd --system --gid tinyproxy --shell /bin/false --no-create-home tinyproxy

# 4. Create necessary directories for logging and PID file, and set permissions
# These paths are based on the default tinyproxy.conf
RUN mkdir -p /var/run/tinyproxy /var/log/tinyproxy && \
    chown -R tinyproxy:tinyproxy /var/run/tinyproxy /var/log/tinyproxy

# 5. Expose the default proxy port
EXPOSE 8888

# 6. Switch to the non-root user
USER tinyproxy

# 7. Set the default command to run tinyproxy in the foreground
#    -d: Do not daemonize (essential for containers)
#    -c: Specify the configuration file
CMD ["/usr/local/bin/tinyproxy", "-d", "-c", "/etc/tinyproxy.conf"]
