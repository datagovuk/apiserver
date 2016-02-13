

tests:
	MIX_ENV=test mix test

prod:
	mix clean
	MIX_ENV=prod mix compile

release: prod
	rm -rf rel/
	MIX_ENV=prod mix release

clean:
	mix clean

full-clean:
	mix clean
	rm -rf deps/
	rm -rf rel/
	mix do deps.get, deps.compile
