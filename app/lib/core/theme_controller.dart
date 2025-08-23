import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateNotifierProvider<ThemeController, ThemeMode>((ref) => ThemeController());

class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system) { _load(); }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getString('theme') ?? 'system';
    state = switch (v) { 'light' => ThemeMode.light, 'dark' => ThemeMode.dark, _ => ThemeMode.system };
  }

  Future<void> toggle() async {
    final next = switch (state) { ThemeMode.light => ThemeMode.dark, ThemeMode.dark => ThemeMode.light, _ => ThemeMode.dark };
    state = next;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('theme', switch (next) { ThemeMode.light => 'light', ThemeMode.dark => 'dark', _ => 'system' });
  }
}