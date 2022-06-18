use term_size;
use termion;
use termsize;

fn main() {
    // term_size
    match term_size::dimensions() {
        Some((width, height)) => println!("term_size -> Height: {}, Width: {}", height, width),
        None => println!("term_size -> Failed to get dimensions"),
    }

    // termsize
    match termsize::get() {
        Some(size) => println!("termsize -> Height: {}, Width: {}", size.rows, size.cols),
        None => println!("termsize -> Failed to get dimensions"),
    }

    // termion
    match termion::terminal_size() {
        Ok((width, height)) => println!("termion -> Height: {}, Width: {}", height, width),
        Err(_err) => println!("termion -> Failed to get dimensions"),
    }
}
