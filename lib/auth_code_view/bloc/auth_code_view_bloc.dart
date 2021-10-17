import 'package:auth_code/core/auth_code_manager.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:oauth2/oauth2.dart';

import '../../auth_code_options.dart';

part 'auth_code_view_event.dart';
part 'auth_code_view_state.dart';

class AuthCodeViewBloc extends Bloc<AuthCodeViewEvent, AuthCodeViewState> {
  final AuthCodeOptions options;
  final AuthCodeManager authCodeManager;
  AuthCodeViewBloc(
    this.options,
  )   : authCodeManager = AuthCodeManager(options),
        super(AuthCodeViewInitial()) {
    on<AuthCodeViewEvent>(
      (event, emit) async {
        if (event is AuthCodeViewLoadedRequestedEvent) {
          emit(AuthCodeViewLoaded(authCodeManager.createAuthorizeEndpoint()));
        }
        if (event is HandleCallbackEvent) {
          emit(HandlingCallback());
          try {
            emit(HandlingCallback());
            final credentials = await authCodeManager
                .createCredentialsFromCallback(event.callbackurl);
            emit(HandlingCallbackSucceeded(credentials));
          } on AuthorizationException catch (authException) {
            emit(HandlingCallbackFailed(
              error: authException.error,
              description: authException.description,
              uri: authException.uri,
            ));
          } on FormatException catch (formatException) {
            emit(HandlingCallbackFailed(error: formatException.message));
          } catch (_) {
            emit(HandlingCallbackFailed(error: 'Unexpected'));
          }
          return;
        }
        if (event is UserInfoRequestedEvent) {
          if (authCodeManager.hasUserInfoEndpoint) {
            emit(FetchingUserInfo());
            try {
              final user = await authCodeManager.getUserInfo();
              emit(FetchingUserInfoSucceeded(user));
            } catch (_) {
              emit(FetchingUserInfoFailed());
            }
          }
          return;
        }
      },
    );
  }
}
