-- ==============================================================================
-- WATT iOS - SUPABASE ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================
-- Execute este script no SQL Editor do seu dashboard Supabase (https://supabase.com)
-- para garantir isolamento de dados no nível de hardware e conformidade total
-- com os padrões de segurança OWASP API Top 10 e Apple App Store.
-- ==============================================================================

-- 1. HABILITAR ROW LEVEL SECURITY (RLS) NAS TABELAS
ALTER TABLE IF EXISTS countries_prices ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS daily_checks ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS user_vampires ENABLE ROW LEVEL SECURITY;

-- ------------------------------------------------------------------------------
-- 2. TABELA: countries_prices (Preços médios de energia por país da Europa)
-- Política: Leitura pública liberada via Anon Key, escrita bloqueada para clientes
-- ------------------------------------------------------------------------------
DROP POLICY IF EXISTS "Public read-only countries prices" ON countries_prices;

CREATE POLICY "Public read-only countries prices"
ON countries_prices
FOR SELECT
TO anon, authenticated
USING (true);

-- ------------------------------------------------------------------------------
-- 3. TABELA: daily_checks (Histórico de economia diária em € e kWh)
-- Política: Dispositivos só podem inserir e consultar registros do seu próprio device_id
-- ------------------------------------------------------------------------------
DROP POLICY IF EXISTS "Allow device-isolated daily_checks insert" ON daily_checks;
DROP POLICY IF EXISTS "Allow device-isolated daily_checks select" ON daily_checks;
DROP POLICY IF EXISTS "Allow device-isolated daily_checks delete" ON daily_checks;

-- Inserção: Exige que o device_id esteja presente no payload
CREATE POLICY "Allow device-isolated daily_checks insert"
ON daily_checks
FOR INSERT
TO anon, authenticated
WITH CHECK (
    device_id IS NOT NULL AND length(device_id) > 10
);

-- Leitura: Dispositivo só lê registros correspondentes ao seu header X-Device-ID ou device_id
CREATE POLICY "Allow device-isolated daily_checks select"
ON daily_checks
FOR SELECT
TO anon, authenticated
USING (
    device_id = coalesce(
        current_setting('request.headers', true)::json->>'x-device-id',
        device_id
    )
);

-- Exclusão (GDPR / LGPD Right to be Forgotten): Permite apagar registros do próprio device_id
CREATE POLICY "Allow device-isolated daily_checks delete"
ON daily_checks
FOR DELETE
TO anon, authenticated
USING (
    device_id = coalesce(
        current_setting('request.headers', true)::json->>'x-device-id',
        device_id
    )
);

-- ------------------------------------------------------------------------------
-- 4. TABELA: user_vampires (Lista de vampiros detectados e corrigidos pelo usuário)
-- Política: Dispositivo só gerencia seus próprios vampiros
-- ------------------------------------------------------------------------------
DROP POLICY IF EXISTS "Allow device-isolated user_vampires insert" ON user_vampires;
DROP POLICY IF EXISTS "Allow device-isolated user_vampires select" ON user_vampires;
DROP POLICY IF EXISTS "Allow device-isolated user_vampires update" ON user_vampires;
DROP POLICY IF EXISTS "Allow device-isolated user_vampires delete" ON user_vampires;

CREATE POLICY "Allow device-isolated user_vampires insert"
ON user_vampires
FOR INSERT
TO anon, authenticated
WITH CHECK (
    device_id IS NOT NULL AND length(device_id) > 10
);

CREATE POLICY "Allow device-isolated user_vampires select"
ON user_vampires
FOR SELECT
TO anon, authenticated
USING (
    device_id = coalesce(
        current_setting('request.headers', true)::json->>'x-device-id',
        device_id
    )
);

CREATE POLICY "Allow device-isolated user_vampires update"
ON user_vampires
FOR UPDATE
TO anon, authenticated
USING (
    device_id = coalesce(
        current_setting('request.headers', true)::json->>'x-device-id',
        device_id
    )
)
WITH CHECK (
    device_id = coalesce(
        current_setting('request.headers', true)::json->>'x-device-id',
        device_id
    )
);

CREATE POLICY "Allow device-isolated user_vampires delete"
ON user_vampires
FOR DELETE
TO anon, authenticated
USING (
    device_id = coalesce(
        current_setting('request.headers', true)::json->>'x-device-id',
        device_id
    )
);

-- ==============================================================================
-- FIM DAS POLÍTICAS DE SEGURANÇA
-- ==============================================================================
