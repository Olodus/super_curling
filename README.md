# Super Curling

A small game about curling.

It is implemented in Zig and uses WASM-4 to run.

## Run

Install WASM-4 (w4), possibly using this command:

```
npm install -g wasm4
```

Build the game using:

```
zig build -Drelease-small=true
```

Run the game using:

```
w4 run zig-out/lib/cart.wasm
```

## Export

To export the game w4 can bundle it for you.
You can find more info on w4 distribution options on their [page](https://wasm4.org/docs/guides/distribution), 
but to get the game as a HTML page use the command:

```
w4 bundle cart.wasm --title "Super Curling" --html super_curling.html
```

## TODO

I want to try and build it with nix.
But WASM-4 doesnt have a nix package yet.
I think I could make that happen using node2nix (but at a first quick try it failed during build... hmm).

