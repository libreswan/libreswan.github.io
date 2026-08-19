## Ways to interact with `unbound`

Keep in mind that with libevent, each thread has a dedicated event
loop.

### `ub_resolve()`

This is a blocking call, using the current thread to do the heavy
lifting.

`libworker_fg()` first checks for cached values with:

- calls `local_zones_answer()` to check for cached result
when present, returns

- calls `auth_zones_downstream_answer()` to check for cached results
when present, return

Assuming there's no cached entry:

- calls `mesh_new_callback()` to setup and start the state machine
  driven by `mesh_run()` and bound to the local thread's event loop

- calls `comm_base_dispatch()` to run the local thread's event loop,
  prodding the state machine in `mesh_run()` as needed

time passes:

- eventually `libworker_fg_done_cb()` is called (via
  `libworker_event_done_cb()`) which stops the local thread's event
  loop, letting `comm_base_dispatch()` return

- the result is unpacked and returned

### `ub_resolve_async()`

This is a non-blocking call where the heavy lifting happens on a
dedicated per-context worker thread.

- when necessary creates the worker using `libworker_bg()`; the thread
  creates a local event loop and the blocks waiting for requests

- the query is wrapped `context_new()` and then sent the worker

- `ub_resolve_async()` returns

time passes, the worker does its magic then:

- completes the the query and appends the response to the context's
  response queue

the main thread:

- uses `ub_fd()` combined with `libevent` or `ub_pool()` to wait for
  the response

- calls `ub_process()` which processes the responses, calling the
  callback when neeeded

### `ub_resolve_event()`

This is a non-blocking call where the heavy lifting happens on the
current thread, but driven using libevent callbacks.

- first, `ub_ctx_create_event()` **and not `ub_ctx_create()`** is
  called to create the context

- `ub_resolve_event()` binds the unbound callbacks to the current
  thread, ñ then returns

time passes, the main thread gets to process unbound callbacks,
including crypto!

- eventually the main thread's event loop calls the `callback()`

This puts the crypto calculations on the main thread!

This creates a context that can't be used in blocking or async modes!

## Notes

I suspect an unbound context can be only used in one of the three
modes above?

I suspect separate contexts don't share results?

Two options:

- The quickest way to get `ttoaddress_dns()` using `unbound` is for
  each call to create a fresh context using `ub_ctx_create()` and then
  use `ub_resolve()`.

  **Danger: `unbound.c`'s unbound_resolve() cannot be used from
  pluto.  It has a libevent context which is wrong.**

- Alternatively, create an async context and use that from the main
  thread.  When there's no `unbound` the helper pool and normal
  resolve could be used.

need to also revist the ipsec dns code
