# Rust terminal dimensions in Docker

**tl;dr:** How to access the host terminal dimensions in a Rust application when running inside Docker?

This example uses three different Rust crates for trying to do this.

## Setup

This repo features a minimal example of what I'm trying to do. You can run it yourself if you have the prerequisites available:

- Rust >= 1.61
- Docker (I'm using Docker Desktop for Mac 4.9)

Build the image with

```bash
docker build -t rust-terminal-dimensions-in-docker .
```

## Debugging steps taken

### 1. Running locally (outside Docker)

```bash
cargo run
```

Output (dimensions depend on your terminal window size):

```bash
    Finished dev [unoptimized + debuginfo] target(s) in 0.03s
     Running `target/debug/rust-terminal-dimensions-in-docker`
term_size -> Height: 48, Width: 101
termsize -> Height: 48, Width: 101
termion -> Height: 48, Width: 101
```

Conclusion: Works as expected.

### 2. Reading the terminal side in Docker, outside the program

It works in **interactive shell when given the command explicitly in the shell** like this:

```bash
docker run -it --entrypoint="" rust-terminal-dimensions-in-docker sh
# Interactive shell active
stty size
```

Outputs (depends on your terminal window size):

```bash
48 101
```

However it **doesn't work when given as a command directly** like this:

```bash
docker run -it --entrypoint="" rust-terminal-dimensions-in-docker stty size
```

Outputs:

```bash
0 0
```

### 3. Running the Dockerized Rust application

At this point, unsurprisingly, we get the 0s we saw above.

```bash
docker run -it rust-terminal-dimensions-in-docker
```

Outputs:

```bash
term_size -> Failed to get dimensions
termsize -> Height: 0, Width: 0
termion -> Height: 0, Width: 0
```

Note that if `-it` is omitted, it won't work at all:

```bash
docker run rust-terminal-dimensions-in-docker
```

Outputs:

```bash
term_size -> Failed to get dimensions
termsize -> Failed to get dimensions
termion -> Failed to get dimensions
```
