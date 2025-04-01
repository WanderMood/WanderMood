-- Creëer moods tabel
CREATE TABLE IF NOT EXISTS moods (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  mood TEXT NOT NULL,
  activity TEXT,
  energy_level NUMERIC NOT NULL CHECK (energy_level >= 1 AND energy_level <= 10),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  
  CONSTRAINT moods_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users (id) ON DELETE CASCADE
);

-- Row Level Security policies
ALTER TABLE moods ENABLE ROW LEVEL SECURITY;

-- Gebruikers kunnen alleen hun eigen stemmingen zien
CREATE POLICY "Gebruikers kunnen alleen hun eigen stemmingen zien"
  ON moods
  FOR SELECT
  USING (auth.uid() = user_id);

-- Gebruikers kunnen alleen hun eigen stemmingen invoegen
CREATE POLICY "Gebruikers kunnen alleen hun eigen stemmingen invoegen"
  ON moods
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Gebruikers kunnen alleen hun eigen stemmingen wijzigen
CREATE POLICY "Gebruikers kunnen alleen hun eigen stemmingen wijzigen"
  ON moods
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Gebruikers kunnen alleen hun eigen stemmingen verwijderen
CREATE POLICY "Gebruikers kunnen alleen hun eigen stemmingen verwijderen"
  ON moods
  FOR DELETE
  USING (auth.uid() = user_id);

-- Index op user_id en created_at voor snelle lookup
CREATE INDEX moods_user_id_created_at_idx ON moods (user_id, created_at DESC);

-- Commentaar
COMMENT ON TABLE moods IS 'Tabel voor het opslaan van gebruikersstemmingen';
COMMENT ON COLUMN moods.mood IS 'De geselecteerde stemming';
COMMENT ON COLUMN moods.activity IS 'De interesse/activiteit categorie';
COMMENT ON COLUMN moods.energy_level IS 'Energieniveau van 1-10';
COMMENT ON COLUMN moods.notes IS 'Aanvullende opmerkingen van de gebruiker'; 