extends Node

signal internet_status_changed(is_online: bool)
signal internet_check_completed(is_online: bool, response_code: int)

const CHECK_INTERVAL_SECONDS := 5.0
const REQUEST_TIMEOUT_SECONDS := 4.0
const CONNECTIVITY_ENDPOINTS := [
	"https://clients3.google.com/generate_204",
	"https://connectivitycheck.gstatic.com/generate_204",
	"https://captive.apple.com/hotspot-detect.html"
]

var is_online: bool = true

var _timer: Timer
var _request: HTTPRequest
var _active_check: bool = false
var _endpoint_index: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	_request = HTTPRequest.new()
	_request.timeout = REQUEST_TIMEOUT_SECONDS
	_request.use_threads = true
	_request.request_completed.connect(_on_request_completed)
	add_child(_request)

	_timer = Timer.new()
	_timer.wait_time = CHECK_INTERVAL_SECONDS
	_timer.one_shot = false
	_timer.timeout.connect(check_connection)
	add_child(_timer)
	_timer.start()

	check_connection()


func check_connection() -> void:
	if _active_check:
		return

	_endpoint_index = 0
	_try_next_endpoint()


func _try_next_endpoint() -> void:
	if _endpoint_index >= CONNECTIVITY_ENDPOINTS.size():
		_set_online_state(false, -1)
		return

	var url: String = CONNECTIVITY_ENDPOINTS[_endpoint_index]
	var headers := PackedStringArray([
		"Cache-Control: no-cache",
		"Pragma: no-cache"
	])

	var err := _request.request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		_endpoint_index += 1
		_try_next_endpoint()
		return

	_active_check = true


func _on_request_completed(
		result: int,
		response_code: int,
		_headers: PackedStringArray,
		_body: PackedByteArray
) -> void:
	_active_check = false

	var success := result == HTTPRequest.RESULT_SUCCESS
	var reachable := success and (response_code == 200 or response_code == 204)

	if reachable:
		_set_online_state(true, response_code)
		return

	_endpoint_index += 1
	_try_next_endpoint()


func _set_online_state(next_state: bool, response_code: int) -> void:
	var changed := is_online != next_state
	is_online = next_state

	internet_check_completed.emit(is_online, response_code)

	if changed:
		internet_status_changed.emit(is_online)
