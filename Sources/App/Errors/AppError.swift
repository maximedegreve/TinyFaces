import Vapor

protocol AppError: AbortError, DebuggableError {}
