# Loaded by direnv. Opt in with `use tmp_build` in a project's .envrc.
use_tmp_build() {
	local cache_root project_id project_cache
	cache_root="/tmp/dev-build-$(id -u)"

	(
		umask 077
		mkdir -p "$cache_root"
	) || return
	if [[ -L "$cache_root" || ! -O "$cache_root" ]]; then
		log_error "Build cache directory is not a private directory owned by you: $cache_root"
		return 1
	fi
	chmod 0700 "$cache_root" || return

	project_id=$(pwd -P | sha256sum | cut -d ' ' -f 1)
	project_cache="$cache_root/$project_id"
	export CARGO_TARGET_DIR="$project_cache/target"
	export PROJECT_BUILD_DIR="$project_cache/build"
	export BENCH_DATA_DIR="$project_cache/bench-data"
	export BENCH_RESULTS_DIR="$HOME/bench-results/$project_id"
	mkdir -p "$CARGO_TARGET_DIR" "$PROJECT_BUILD_DIR" "$BENCH_DATA_DIR" "$BENCH_RESULTS_DIR"
}
