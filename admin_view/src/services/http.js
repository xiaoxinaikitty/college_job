const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080'
const AUTH_KEY = 'college-job-admin-auth'

function buildUrl(path, query) {
  const url = new URL(path, API_BASE_URL)
  if (!query) {
    return url.toString()
  }
  Object.entries(query).forEach(([key, value]) => {
    if (value === null || value === undefined || value === '') {
      return
    }
    url.searchParams.set(key, String(value))
  })
  return url.toString()
}

function readAuthSnapshot() {
  try {
    const raw = localStorage.getItem(AUTH_KEY)
    if (!raw) {
      return { token: '', user: null }
    }
    const parsed = JSON.parse(raw)
    return {
      token: parsed?.token || '',
      user: parsed?.user || null,
    }
  } catch {
    return { token: '', user: null }
  }
}

export async function httpRequest(path, options = {}) {
  const {
    method = 'GET',
    query,
    body,
    headers = {},
    withAuth = true,
  } = options

  const requestHeaders = { ...headers }
  if (body !== undefined) {
    requestHeaders['Content-Type'] = 'application/json'
  }

  if (withAuth) {
    const auth = readAuthSnapshot()
    if (auth.token) {
      requestHeaders.Authorization = `Bearer ${auth.token}`
    }
    if (auth.user?.id) {
      requestHeaders['X-User-Id'] = String(auth.user.id)
    }
  }

  let response
  try {
    response = await fetch(buildUrl(path, query), {
      method,
      headers: requestHeaders,
      body: body === undefined ? undefined : JSON.stringify(body),
    })
  } catch (error) {
    throw new Error('网络异常，请检查后端服务是否启动')
  }

  let payload = null
  try {
    payload = await response.json()
  } catch {
    payload = null
  }

  if (!response.ok) {
    const message = payload?.message || `请求失败(${response.status})`
    throw new Error(message)
  }

  if (!payload || typeof payload.code !== 'number') {
    throw new Error('接口返回格式异常')
  }
  if (payload.code !== 0) {
    throw new Error(payload.message || '接口调用失败')
  }
  return payload.data
}

