import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/blood_types.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/egypt_location_fields.dart';
import '../../../../l10n/app_localizations.dart';

enum AuthMode { login, register, recovery }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.mode});
  final AuthMode mode;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  bool _hidden = true;
  bool _submitted = false;
  String? _bloodType;
  bool get _login => widget.mode == AuthMode.login;
  bool get _register => widget.mode == AuthMode.register;

  void _unavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.authUnavailable)),
    );
  }

  void _submit() {
    setState(() => _submitted = true);
    if (_form.currentState!.validate() && (!_register || _bloodType != null)) {
      _unavailable();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: AutofillGroup(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_login) _brand(t),
                    Padding(
                      padding: EdgeInsets.fromLTRB(24, 12, 24, 36),
                      child: Form(
                        key: _form,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!_login) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton.filledTonal(
                                    tooltip: MaterialLocalizations.of(context)
                                        .backButtonTooltip,
                                    onPressed: () => context.go('/auth'),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.ink,
                                      side: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                      fixedSize: const Size(44, 44),
                                    ),
                                    icon: const BackButtonIcon(),
                                  ),
                                  if (_register)
                                    Text(
                                      t.stepOneOfTwo,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (!_login && !_register) ...[
                              const SizedBox(height: 36),
                              Center(
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: const Icon(
                                    Icons.lock_reset_rounded,
                                    size: 44,
                                    color: AppColors.red,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                            ],
                            Text(
                              _login
                                  ? t.welcomeBack
                                  : _register
                                  ? t.createAccount
                                  : t.forgotPassword,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                height: 1.6,
                              ),
                            ),
                            if (!_login) ...[
                              const SizedBox(height: 4),
                              Text(
                                _register
                                    ? t.registerSubtitle
                                    : t.recoverySubtitle,
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 13,
                                  height: 1.8,
                                ),
                              ),
                            ],
                            if (_register) ...[
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  for (final active in [true, false])
                                    Expanded(
                                      child: Container(
                                        height: 5,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: active
                                              ? AppColors.ink
                                              : AppColors.border,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 8),
                            if (_register) ...[
                              _label(t.fullName),
                              _field(
                                hint: t.fullNameHint,
                                autofillHints: const [AutofillHints.name],
                                validator: (value) =>
                                    (value ?? '').trim().length >= 2
                                    ? null
                                    : t.requiredField,
                              ),
                              const SizedBox(height: 18),
                            ],
                            _label(t.mobileNumber),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 52,
                                    width: 72,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: AppColors.border,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Text(
                                      '+20',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: _field(
                                      hint: '010 1234 5678',
                                      keyboardType: TextInputType.phone,
                                      autofillHints: const [
                                        AutofillHints.telephoneNumberNational,
                                      ],
                                      formatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(11),
                                      ],
                                      validator: (value) =>
                                          RegExp(r'^01[0125]\d{8}$')
                                              .hasMatch(value ?? '')
                                          ? null
                                          : t.invalidPhone,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_login || _register) ...[
                              const SizedBox(height: 8),
                              _label(t.passwordLabel),
                              _field(
                                hint: '••••••••',
                                obscure: _hidden,
                                autofillHints: [
                                  _register
                                      ? AutofillHints.newPassword
                                      : AutofillHints.password,
                                ],
                                validator: (value) =>
                                    (value ?? '').length >= (_register ? 8 : 1)
                                    ? null
                                    : (_register
                                          ? t.passwordTooShort
                                          : t.requiredField),
                                suffix: IconButton(
                                  tooltip: _hidden
                                      ? t.showPassword
                                      : t.hidePassword,
                                  onPressed: () =>
                                      setState(() => _hidden = !_hidden),
                                  icon: Icon(
                                    _hidden
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 19,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                            ],
                            if (_login) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: TextButton(
                                  onPressed: () =>
                                      context.push('/auth/forgot-password'),
                                  child: Text(
                                    t.forgotPassword,
                                    style: _linkStyle,
                                  ),
                                ),
                              ),
                            ],
                            if (_register) ...[
                              const SizedBox(height: 18),
                              _label(t.yourBloodType),
                              GridView.count(
                                crossAxisCount: 4,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio: 1.75,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                children: [
                                  for (final type in BloodTypes.values)
                                    Semantics(
                                      selected: _bloodType == type,
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          backgroundColor: _bloodType == type
                                              ? AppColors.red
                                              : Colors.white,
                                          foregroundColor: _bloodType == type
                                              ? Colors.white
                                              : AppColors.ink,
                                          side: BorderSide(
                                            color: _bloodType == type
                                                ? AppColors.red
                                                : AppColors.border,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        onPressed: () =>
                                            setState(() => _bloodType = type),
                                        child: Text(
                                          type,
                                          textDirection: TextDirection.ltr,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (_submitted && _bloodType == null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    t.chooseBloodType,
                                    style: const TextStyle(
                                      color: AppColors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 18),
                              const EgyptLocationFields(),
                            ],
                            const SizedBox(height: 10),
                            _button(
                              _login
                                  ? t.loginAction
                                  : _register
                                  ? t.continueAction
                                  : t.sendRecoveryCode,
                              _submit,
                            ),
                            if (_login) ...[
                              const SizedBox(height: 10),
                              _button(
                                t.continueGuest,
                                _unavailable,
                                outlined: true,
                              ),
                            ],
                            const SizedBox(height: 8),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  _login
                                      ? t.noAccount
                                      : _register
                                      ? t.haveAccount
                                      : t.rememberPassword,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.muted,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _login
                                      ? context.push('/auth/register')
                                      : context.go('/auth'),
                                  child: Text(
                                    _login ? t.registerNow : t.loginAction,
                                    style: _linkStyle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const _linkStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: AppColors.red,
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF403838),
      ),
    ),
  );

  Widget _field({
    String? hint,
    bool obscure = false,
    TextInputType? keyboardType,
    Iterable<String>? autofillHints,
    List<TextInputFormatter>? formatters,
    FormFieldValidator<String>? validator,
    Widget? suffix,
  }) => TextFormField(
    obscureText: obscure,
    keyboardType: keyboardType,
    autofillHints: autofillHints,
    inputFormatters: formatters,
    validator: validator,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.muted,
        fontWeight: FontWeight.w400,
      ),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      errorMaxLines: 2,
    ),
  );

  Widget _button(
    String label,
    VoidCallback onPressed, {
    bool outlined = false,
  }) {
    final text = Text(
      label,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
    );
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ink,
                side: const BorderSide(color: AppColors.ink),
              ),
              child: text,
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(elevation: 0),
              child: text,
            ),
    );
  }

  Widget _brand(AppLocalizations t) => Container(
    height: (MediaQuery.sizeOf(context).height * .27).clamp(140.0, 220.0),
    decoration: const BoxDecoration(
      color: AppColors.ink,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 38,
          height: 52,
          child: CustomPaint(painter: _BloodDropPainter()),
        ),
        const SizedBox(height: 16),
        Text(
          t.authBrand,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t.authTagline,
          style: const TextStyle(fontSize: 14, color: Color(0xFFCCC4C1)),
        ),
      ],
    ),
  );
}

class _BloodDropPainter extends CustomPainter {
  const _BloodDropPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..cubicTo(
        size.width * .29,
        size.height * .20,
        0,
        size.height * .48,
        0,
        size.height * .65,
      )
      ..cubicTo(
        0,
        size.height * 1.12,
        size.width,
        size.height * 1.12,
        size.width,
        size.height * .65,
      )
      ..cubicTo(
        size.width,
        size.height * .48,
        size.width * .71,
        size.height * .20,
        size.width / 2,
        0,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.redOnDark);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
