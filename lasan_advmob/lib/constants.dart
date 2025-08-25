import 'package:flutter_dotenv/flutter_dotenv.dart';

// Fallback to production host if .env is missing or not loaded in some builds
final String host = (dotenv.env['HOST'] ?? 'https://advweb-backend.vercel.app');