#include "sessionshim.hpp"

#include <new>
#include <string>

#include <grpcpp/create_channel.h>
#include <grpcpp/security/credentials.h>

#include "session.grpc.pb.h"

struct SessionClient {
  std::shared_ptr<grpc::Channel> channel;
  std::unique_ptr<purrboss::v1::SessionService::Stub> stub;
  std::string last_error;
  purrboss::v1::CreateSessionResponse create_session_response;
  purrboss::v1::ValidateSessionResponse validate_session_response;
  purrboss::v1::InvalidateSessionResponse invalidate_session_response;
  purrboss::v1::PingResponse ping_response;
};

namespace {

bool apply_status(SessionClient *client, const grpc::Status &status) {
  if (status.ok()) {
    client->last_error.clear();
    return true;
  }
  client->last_error = status.error_message();
  return false;
}

}  // namespace

SessionClient *session_client_create(const char *target) {
  auto *client = new (std::nothrow) SessionClient;
  if (client == nullptr) return nullptr;
  client->channel =
      grpc::CreateChannel(target, grpc::InsecureChannelCredentials());
  client->stub = purrboss::v1::SessionService::NewStub(client->channel);
  return client;
}

void session_client_destroy(SessionClient *client) { delete client; }

const char *session_client_error(SessionClient *client) {
  return client->last_error.c_str();
}

bool session_client_create_session(SessionClient *client, const char *user_id,
                                   int64_t ttl_seconds,
                                   const char **out_session_key,
                                   int64_t *out_expires_at_seconds) {
  purrboss::v1::CreateSessionRequest request;
  request.set_user_id(user_id);
  request.set_ttl_seconds(ttl_seconds);

  grpc::ClientContext context;
  grpc::Status status = client->stub->CreateSession(
      &context, request, &client->create_session_response);
  if (!apply_status(client, status)) return false;

  *out_session_key = client->create_session_response.session_key().c_str();
  *out_expires_at_seconds =
      client->create_session_response.expires_at().seconds();
  return true;
}

bool session_client_validate_session(SessionClient *client,
                                     const char *session_key,
                                     bool force_refresh, bool *out_valid,
                                     const char **out_user_id,
                                     const char **out_reason,
                                     int64_t *out_expires_at_seconds) {
  purrboss::v1::ValidateSessionRequest request;
  request.set_session_key(session_key);
  request.set_force_refresh(force_refresh);

  grpc::ClientContext context;
  grpc::Status status = client->stub->ValidateSession(
      &context, request, &client->validate_session_response);
  if (!apply_status(client, status)) return false;

  *out_valid = client->validate_session_response.valid();
  *out_user_id = client->validate_session_response.user_id().c_str();
  *out_reason = client->validate_session_response.reason().c_str();
  *out_expires_at_seconds =
      client->validate_session_response.expires_at().seconds();
  return true;
}

bool session_client_invalidate_session(SessionClient *client,
                                       const char *session_key,
                                       const char *reason, bool *out_success) {
  purrboss::v1::InvalidateSessionRequest request;
  request.set_session_key(session_key);
  request.set_reason(reason);

  grpc::ClientContext context;
  grpc::Status status = client->stub->InvalidateSession(
      &context, request, &client->invalidate_session_response);
  if (!apply_status(client, status)) return false;

  *out_success = client->invalidate_session_response.success();
  return true;
}

bool session_client_ping(SessionClient *client, bool *out_healthy,
                         int64_t *out_server_time_seconds) {
  purrboss::v1::PingRequest request;

  grpc::ClientContext context;
  grpc::Status status =
      client->stub->Ping(&context, request, &client->ping_response);
  if (!apply_status(client, status)) return false;

  *out_healthy = client->ping_response.ok();
  *out_server_time_seconds = client->ping_response.server_time().seconds();
  return true;
}
