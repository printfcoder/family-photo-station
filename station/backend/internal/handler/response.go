package handler

// Response 统一响应格式
type Response struct {
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

// PageResponse 分页响应格式
type PageResponse struct {
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
	Page    PageInfo    `json:"page"`
}

// PageInfo 分页信息
type PageInfo struct {
	Current   int   `json:"current"`    // 当前页码
	Size      int   `json:"size"`       // 每页大小
	Total     int64 `json:"total"`      // 总记录数
	TotalPage int   `json:"total_page"` // 总页数
}

// SuccessResponse 成功响应
func SuccessResponse(message string, data interface{}) Response {
	return Response{
		Code:    200,
		Message: message,
		Data:    data,
	}
}

// ErrorResponse 错误响应
func ErrorResponse(code int, message string, err error) Response {
	resp := Response{
		Code:    code,
		Message: message,
	}
	if err != nil {
		resp.Error = err.Error()
	}
	return resp
}

// PageSuccessResponse 分页成功响应
func PageSuccessResponse(message string, data interface{}, page PageInfo) PageResponse {
	return PageResponse{
		Code:    200,
		Message: message,
		Data:    data,
		Page:    page,
	}
}