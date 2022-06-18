# Rust terminal dimensions in Docker

**tl;dr:** How to access the host terminal dimensions in a Rust application when running inside Docker?

This example uses three different Rust crates for trying to do this.

**Answer:** Due to a Docker race condition bug, you need a tiny hack to enable this. And don't forget to run with `-it`.

## Setup

This repo features a minimal example of what I'm trying to do. You can run it yourself if you have the prerequisites available:

- Rust >= 1.61
- Docker (I'm using Docker Desktop for Mac 4.9)

Build the **failing** image with

```bash
docker build -t fail -f Dockerfile.fail .
```

and the **success** image with

```bash
docker build -t success -f Dockerfile.success .
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
docker run -it --entrypoint="" fail sh
# Interactive shell active
stty size
```

Outputs (depends on your terminal window size):

```bash
48 101
```

However it **doesn't work when given as a command directly** like this:

```bash
docker run -it --entrypoint="" fail stty size
```

Outputs:

```bash
0 0
```

### 3. Running the Dockerized Rust application

At this point, unsurprisingly, we get the 0s we saw above.

```bash
docker run -it fail
```

Outputs:

```bash
term_size -> Failed to get dimensions
termsize -> Height: 0, Width: 0
termion -> Height: 0, Width: 0
```

Note that if `-it` is omitted, it won't work at all:

```bash
docker run fail
```

Outputs:

```bash
term_size -> Failed to get dimensions
termsize -> Failed to get dimensions
termion -> Failed to get dimensions
```

## Solution

Turns out it's a bug in Docker. Here is an issue describing it https://github.com/docker/for-linux/issues/314. Thanks to helpful people in [Koodiklinikka](https://koodiklinikka.fi/) for showing the solution 🙏

What you need to do is – like with so many programming problems – get some `sleep` first. So for example this works:

```bash
docker run -it --entrypoint="" fail sh -c "sleep 1; stty size"
```

Outputs (depending on your terminal window size):

```bash
48 101
```

And this is fixed in [`Dockerfile.success`](/Dockerfile.success):

```Dockerfile
# This works, the "sleep 1" buys enough time for the race condition
ENTRYPOINT ["/bin/sh", "-c", "sleep 1; ./rust-terminal-dimensions-in-docker"]
```

So if you [build the `success` image](#setup), it now works:

```bash
docker run -it success
```

Outputs (depending on your terminal window size):

```bash
term_size -> Height: 48, Width: 101
termsize -> Height: 48, Width: 101
termion -> Height: 48, Width: 101
```

**Note that you need the `-it` flag**, otherwise it won't find the tty:

```bash
docker run success
```

Outputs:

```bash
term_size -> Failed to get dimensions
termsize -> Failed to get dimensions
termion -> Failed to get dimensions
```
