import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/common/app_images.dart';
import '../../core/themes/app_fonts.dart';

enum FormType { inputText, inputPassword, inputNumber }

class FormTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String svgIconPath;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool enable;
  final Function(String e)? onChange;
  final FormFieldValidator<String>? validator;
  final FormType formType;

  const FormTextField({
    super.key,
    required this.controller,
    this.label = "",
    this.hintText = "",
    this.svgIconPath = "",
    this.onChange,
    this.validator,
    this.formType = FormType.inputText,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.enable = true,
  });

  @override
  State<FormTextField> createState() => _FormTextFieldState();
}

class _FormTextFieldState extends State<FormTextField> {
  bool passwordVisible = true;

  @override
  void initState() {
    super.initState();
    passwordVisible = widget.formType == FormType.inputPassword ? false : true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      width: double.infinity,
      child: TextFormField(
        enabled: widget.enable,
        controller: widget.controller,
        obscureText: !passwordVisible,
        style: appFonts.medium.bodyLarge.tsInter,
        keyboardType: widget.keyboardType,
        onChanged: (e) {
          if (widget.onChange != null) {
            widget.onChange!(e);
          }
        },
        decoration: InputDecoration(
          prefixIconConstraints: widget.svgIconPath.isEmpty
              ? null
              : const BoxConstraints(maxHeight: 24, maxWidth: 50),
          prefixIcon: widget.svgIconPath.isEmpty
              ? null
              : Padding(
                  padding: const EdgeInsets.only(left: 16, right: 10),
                  child: Center(child: SvgPicture.asset(widget.svgIconPath)),
                ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFd9d9d9), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xff11A791), width: 2),
          ),
          hintText: widget.hintText,
          suffixIcon: widget.formType == FormType.inputPassword
              ? IconButton(
                  icon: SvgPicture.asset(
                    passwordVisible
                        ? AppImages.iconHidePass
                        : AppImages.iconShowPass,
                    width: 21,
                    height: 17,
                  ),
                  onPressed: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                )
              : null,
          label: Text(widget.label, style: appFonts.gray.light.tsInter),
        ),
        validator: widget.validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }
}
