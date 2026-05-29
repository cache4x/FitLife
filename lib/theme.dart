import 'package:flutter/material.dart';

// Paleta de cores global do aplicativo (estilo escuro e vibrante)
const kYellow   = Color(0xFFF5D10D); // Cor de destaque principal (Amarelo)
const kBg       = Color(0xFF0E1116); // Cor de fundo principal da aplicação
const kCard     = Color(0xFF1C2027); // Cor de fundo dos cartões/containers
const kBorder   = Color(0xFF2A2F38); // Cor padrão de bordas e divisores
const kMuted    = Color(0xFF9AA0A6); // Cor cinza para textos secundários ou desabilitados

// Função que constrói e retorna a configuração de tema global do aplicativo
ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBg,
    
    // Configuração das cores padrão para o esquema do Material Design
    colorScheme: const ColorScheme.dark(
      primary:   kYellow,
      onPrimary: kBg,
      surface:   kCard,
      onSurface: Colors.white,
    ),
    
    // Customização visual da barra de topo (AppBar)
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF181B21),
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    
    // Customização visual dos Cards
    cardTheme: CardThemeData(
      color: kCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: kBorder),
      ),
      elevation: 0,
    ),
    
    // Estilo padrão para botões principais preenchidos (ElevatedButton)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kYellow,
        foregroundColor: kBg,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    
    // Estilo padrão para botões de contorno (OutlinedButton)
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kYellow,
        side: const BorderSide(color: kYellow),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    
    // Configuração global para campos de entrada de formulários (Inputs)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kYellow, width: 2),
      ),
      labelStyle: const TextStyle(color: kMuted),
      hintStyle: const TextStyle(color: kMuted),
    ),
    
    // Configuração de cores de textos globais
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
      bodyLarge:  TextStyle(color: Colors.white),
    ),
    
    dividerColor: kBorder,
    
    // Estilo do botão flutuante de ação (FloatingActionButton)
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kYellow,
      foregroundColor: kBg,
    ),
    
    // Estilo de chips de tags de seleção
    chipTheme: ChipThemeData(
      backgroundColor: kCard,
      side: const BorderSide(color: kBorder),
      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
