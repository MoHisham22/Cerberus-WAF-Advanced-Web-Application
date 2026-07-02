local ngx = ngx
local ngx_req = ngx.req
local ngx_header = ngx.header
local ngx_exit = ngx.exit
local NGX_HTTP_UNAUTHORIZED = ngx.HTTP_UNAUTHORIZED
local string_find = string.find
local string_sub = string.sub
local base64_decode = ngx.decode_base64

local users = {
    admin = "admin123",
    user1 = "password1",
    test = "test123"
}

local function decode_base64_authorization(auth_header)
    if not auth_header then return nil end

    local prefix = "Basic "
    if string_find(auth_header, prefix) ~= 1 then
        return nil
    end

    local encoded = string_sub(auth_header, #prefix + 1)
    return base64_decode(encoded)
end

local function authenticate(credentials)
    if not credentials then return false end

    local colon_pos = string_find(credentials, ":")
    if not colon_pos then return false end

    local username = string_sub(credentials, 1, colon_pos - 1)
    local password = string_sub(credentials, colon_pos + 1)

    if users[username] and users[username] == password then
        return true
    end

    return false
end

local function basic_auth()
    local auth_header = ngx_req.get_headers()["Authorization"]

    if not auth_header then
        ngx_header["WWW-Authenticate"] = 'Basic realm="Secure Area"'
        ngx_exit(NGX_HTTP_UNAUTHORIZED)
        return
    end

    local credentials = decode_base64_authorization(auth_header)
    if not credentials or not authenticate(credentials) then
        ngx_header["WWW-Authenticate"] = 'Basic realm="Secure Area"'
        ngx_exit(NGX_HTTP_UNAUTHORIZED)
        return
    end
end

local _M = {
    version = 0.1,
    name = "basic-auth",
    priority = 1
}

function _M.req_pre_filter(waf)
    basic_auth()
end

return _M