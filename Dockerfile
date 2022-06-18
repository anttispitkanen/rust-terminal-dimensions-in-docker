###############################################################################
## Build stage
###############################################################################
FROM rust:1.61 as build

RUN USER=root cargo new --bin rust-terminal-dimensions-in-docker
WORKDIR /rust-terminal-dimensions-in-docker

COPY ./Cargo.lock ./
COPY ./Cargo.toml ./

RUN cargo build --release

COPY ./src ./src

RUN rm ./target/release/deps/*
RUN cargo build --release

###############################################################################
## Release stage
###############################################################################
FROM rust:1.61 as release

COPY --from=build /rust-terminal-dimensions-in-docker/target/release/rust-terminal-dimensions-in-docker .

ENTRYPOINT ["./rust-terminal-dimensions-in-docker"]
