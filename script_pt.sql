-- ============================================================
-- MuscleHelper - Script de criação do banco em PORTUGUÊS
-- Execute no SQL Server Management Studio (SSMS)
-- ============================================================

USE BDMuscleHelper;
GO

-- 1) Apaga tabelas antigas (inglês ou parciais), se existirem
IF OBJECT_ID('dbo.Exercise', 'U') IS NOT NULL DROP TABLE [Exercise];
IF OBJECT_ID('dbo.Exercício', 'U') IS NOT NULL DROP TABLE [Exercício];
IF OBJECT_ID('dbo.MuscleGroup', 'U') IS NOT NULL DROP TABLE [MuscleGroup];
IF OBJECT_ID('dbo.GrupoMuscular', 'U') IS NOT NULL DROP TABLE [GrupoMuscular];
GO

-- 2) Tabela GrupoMuscular
CREATE TABLE [GrupoMuscular] (
    [Id]         NVARCHAR(450) NOT NULL,
    [Nome]       NVARCHAR(MAX) NOT NULL,
    [Região]     NVARCHAR(MAX) NOT NULL,
    [IconeEmoji] NVARCHAR(MAX) NOT NULL,
    CONSTRAINT PK_GrupoMuscular PRIMARY KEY ([Id])
);
GO

-- 3) Tabela Exercício
CREATE TABLE [Exercício] (
    [Id]              NVARCHAR(450) NOT NULL,
    [Nome]            NVARCHAR(MAX) NOT NULL,
    [Descrição]       NVARCHAR(MAX) NOT NULL,
    [Dificuldade]     NVARCHAR(MAX) NOT NULL,
    [Equipamento]     NVARCHAR(MAX) NOT NULL,
    [Passos]          NVARCHAR(MAX) NOT NULL,
    [UrlImagem]       NVARCHAR(MAX) NOT NULL,
    [GrupoMuscularId] NVARCHAR(450) NOT NULL,
    CONSTRAINT PK_Exercício PRIMARY KEY ([Id]),
    CONSTRAINT FK_Exercício_GrupoMuscular
        FOREIGN KEY ([GrupoMuscularId])
        REFERENCES [GrupoMuscular]([Id])
        ON DELETE CASCADE
);
GO

CREATE INDEX IX_Exercício_GrupoMuscularId ON [Exercício]([GrupoMuscularId]);
GO

-- 4) Seed dos grupos musculares
INSERT INTO [GrupoMuscular] ([Id], [Nome], [Região], [IconeEmoji]) VALUES
    ('peito',       N'Peito',       N'Frente', N'💪'),
    ('ombros',      N'Ombros',      N'Frente', N'🏋️'),
    ('biceps',      N'Bíceps',      N'Frente', N'💪'),
    ('abdomen',     N'Abdômen',     N'Frente', N'🔥'),
    ('quadriceps',  N'Quadríceps',  N'Frente', N'🦵'),
    ('costas',      N'Costas',      N'Costas', N'🔙'),
    ('triceps',     N'Tríceps',     N'Costas', N'💪'),
    ('gluteos',     N'Glúteos',     N'Costas', N'🍑'),
    ('posteriores', N'Posteriores', N'Costas', N'🦵'),
    ('panturrilha', N'Panturrilha', N'Costas', N'🦵');
GO

-- 5) Seed de exercícios (2 por grupo muscular)
INSERT INTO [Exercício] ([Id], [Nome], [Descrição], [Dificuldade], [Equipamento], [Passos], [UrlImagem], [GrupoMuscularId]) VALUES

-- PEITO
('ex-peito-supino',
 N'Supino Reto',
 N'Exercício clássico para desenvolvimento do peitoral maior, ombros e tríceps.',
 N'Iniciante', N'Barra',
 N'1. Deite no banco com os pés apoiados no chão' + CHAR(10) +
 N'2. Segure a barra com pegada um pouco mais larga que os ombros' + CHAR(10) +
 N'3. Desça a barra controladamente até tocar o peito' + CHAR(10) +
 N'4. Empurre a barra de volta até estender os braços',
 N'', N'peito'),

('ex-peito-crucifixo',
 N'Crucifixo com Halteres',
 N'Exercício de isolamento focado no peitoral, com grande amplitude de movimento.',
 N'Intermediário', N'Halteres',
 N'1. Deite no banco com um halter em cada mão' + CHAR(10) +
 N'2. Estenda os braços acima do peito com leve flexão dos cotovelos' + CHAR(10) +
 N'3. Abra os braços lateralmente até sentir alongamento no peito' + CHAR(10) +
 N'4. Retorne à posição inicial contraindo o peitoral',
 N'', N'peito'),

-- OMBROS
('ex-ombros-desenvolvimento',
 N'Desenvolvimento Militar',
 N'Exercício composto que trabalha principalmente o deltoide anterior e medial.',
 N'Intermediário', N'Barra',
 N'1. Em pé, segure a barra na altura dos ombros' + CHAR(10) +
 N'2. Mantenha o core contraído e a coluna neutra' + CHAR(10) +
 N'3. Empurre a barra para cima até estender os braços' + CHAR(10) +
 N'4. Desça controladamente até a posição inicial',
 N'', N'ombros'),

('ex-ombros-elevacao-lateral',
 N'Elevação Lateral',
 N'Isolamento do deltoide medial para construção de ombros largos.',
 N'Iniciante', N'Halteres',
 N'1. Em pé, segure um halter em cada mão ao lado do corpo' + CHAR(10) +
 N'2. Mantenha leve flexão nos cotovelos' + CHAR(10) +
 N'3. Eleve os braços lateralmente até a altura dos ombros' + CHAR(10) +
 N'4. Desça controladamente sem balançar o corpo',
 N'', N'ombros'),

-- BÍCEPS
('ex-biceps-rosca-direta',
 N'Rosca Direta',
 N'Exercício clássico para hipertrofia do bíceps braquial.',
 N'Iniciante', N'Barra',
 N'1. Em pé, segure a barra com pegada supinada' + CHAR(10) +
 N'2. Mantenha os cotovelos junto ao corpo' + CHAR(10) +
 N'3. Flexione os cotovelos elevando a barra até a altura do peito' + CHAR(10) +
 N'4. Desça controladamente sem balançar',
 N'', N'biceps'),

('ex-biceps-martelo',
 N'Rosca Martelo',
 N'Trabalha o bíceps e o braquial, dando volume ao braço.',
 N'Iniciante', N'Halteres',
 N'1. Em pé, segure um halter em cada mão com pegada neutra' + CHAR(10) +
 N'2. Mantenha os cotovelos colados ao tronco' + CHAR(10) +
 N'3. Flexione os cotovelos como se estivesse martelando' + CHAR(10) +
 N'4. Retorne à posição inicial controladamente',
 N'', N'biceps'),

-- ABDÔMEN
('ex-abdomen-prancha',
 N'Prancha',
 N'Exercício isométrico que fortalece todo o core, sem impacto.',
 N'Iniciante', N'Peso Corporal',
 N'1. Apoie os antebraços e as pontas dos pés no chão' + CHAR(10) +
 N'2. Mantenha o corpo alinhado da cabeça aos calcanhares' + CHAR(10) +
 N'3. Contraia o abdômen e os glúteos' + CHAR(10) +
 N'4. Sustente a posição por 30 a 60 segundos',
 N'', N'abdomen'),

('ex-abdomen-supra',
 N'Abdominal Supra',
 N'Movimento básico de contração do reto abdominal.',
 N'Iniciante', N'Peso Corporal',
 N'1. Deite com os joelhos flexionados e os pés no chão' + CHAR(10) +
 N'2. Coloque as mãos atrás da cabeça sem puxar o pescoço' + CHAR(10) +
 N'3. Eleve o tronco contraindo o abdômen' + CHAR(10) +
 N'4. Desça controladamente até quase encostar no chão',
 N'', N'abdomen'),

-- QUADRÍCEPS
('ex-quadriceps-agachamento',
 N'Agachamento Livre',
 N'Considerado o rei dos exercícios para membros inferiores.',
 N'Avançado', N'Barra',
 N'1. Posicione a barra no trapézio com os pés afastados na largura dos ombros' + CHAR(10) +
 N'2. Desça flexionando joelhos e quadris simultaneamente' + CHAR(10) +
 N'3. Mantenha a coluna ereta e o peito aberto' + CHAR(10) +
 N'4. Suba empurrando o chão com os calcanhares',
 N'', N'quadriceps'),

('ex-quadriceps-leg-press',
 N'Leg Press 45º',
 N'Excelente para iniciantes e ideal para sobrecarga sem comprometer a coluna.',
 N'Intermediário', N'Máquina',
 N'1. Sente-se na máquina com as costas bem apoiadas' + CHAR(10) +
 N'2. Posicione os pés na plataforma na largura dos ombros' + CHAR(10) +
 N'3. Desça flexionando os joelhos até 90 graus' + CHAR(10) +
 N'4. Empurre a plataforma de volta sem travar os joelhos',
 N'', N'quadriceps'),

-- COSTAS
('ex-costas-barra-fixa',
 N'Barra Fixa',
 N'Exercício composto que trabalha grande dorsal, bíceps e antebraços.',
 N'Avançado', N'Peso Corporal',
 N'1. Pendure-se na barra com pegada pronada e mais aberta que os ombros' + CHAR(10) +
 N'2. Contraia o core e puxe o corpo para cima' + CHAR(10) +
 N'3. Eleve até o queixo passar a barra' + CHAR(10) +
 N'4. Desça controladamente até estender os braços',
 N'', N'costas'),

('ex-costas-remada-curvada',
 N'Remada Curvada',
 N'Exercício essencial para desenvolvimento da espessura do dorso.',
 N'Intermediário', N'Barra',
 N'1. Em pé, com tronco inclinado a 45 graus e coluna neutra' + CHAR(10) +
 N'2. Segure a barra com pegada pronada' + CHAR(10) +
 N'3. Puxe a barra em direção ao abdômen' + CHAR(10) +
 N'4. Desça controladamente estendendo os braços',
 N'', N'costas'),

-- TRÍCEPS
('ex-triceps-pulley',
 N'Tríceps na Polia',
 N'Exercício de isolamento com corda ou barra na polia alta.',
 N'Iniciante', N'Cabos',
 N'1. Em pé de frente para a polia alta, segure a barra' + CHAR(10) +
 N'2. Mantenha os cotovelos colados ao tronco' + CHAR(10) +
 N'3. Estenda os braços empurrando a barra para baixo' + CHAR(10) +
 N'4. Retorne controladamente sem afastar os cotovelos',
 N'', N'triceps'),

('ex-triceps-frances',
 N'Tríceps Francês',
 N'Foca na cabeça longa do tríceps com grande alongamento.',
 N'Intermediário', N'Halteres',
 N'1. Deite no banco segurando um halter com as duas mãos acima da cabeça' + CHAR(10) +
 N'2. Mantenha os cotovelos apontados para o teto' + CHAR(10) +
 N'3. Flexione os cotovelos descendo o halter atrás da cabeça' + CHAR(10) +
 N'4. Estenda os braços de volta à posição inicial',
 N'', N'triceps'),

-- GLÚTEOS
('ex-gluteos-elevacao-pelvica',
 N'Elevação Pélvica (Hip Thrust)',
 N'O melhor exercício para hipertrofia dos glúteos.',
 N'Iniciante', N'Peso Corporal',
 N'1. Apoie a parte superior das costas em um banco' + CHAR(10) +
 N'2. Flexione os joelhos com os pés apoiados no chão' + CHAR(10) +
 N'3. Eleve o quadril contraindo os glúteos' + CHAR(10) +
 N'4. Desça controladamente sem encostar totalmente no chão',
 N'', N'gluteos'),

('ex-gluteos-polia',
 N'Glúteo na Polia',
 N'Isolamento dos glúteos com sobrecarga progressiva.',
 N'Intermediário', N'Cabos',
 N'1. Prenda a caneleira no tornozelo e na polia baixa' + CHAR(10) +
 N'2. Em pé, segure-se no suporte para equilíbrio' + CHAR(10) +
 N'3. Estenda a perna para trás contraindo o glúteo' + CHAR(10) +
 N'4. Retorne controladamente à posição inicial',
 N'', N'gluteos'),

-- POSTERIORES
('ex-posteriores-stiff',
 N'Stiff',
 N'Exercício composto focado em posteriores de coxa e glúteos.',
 N'Avançado', N'Barra',
 N'1. Em pé, segure a barra com pegada pronada à frente do corpo' + CHAR(10) +
 N'2. Mantenha leve flexão nos joelhos' + CHAR(10) +
 N'3. Incline o tronco à frente empurrando o quadril para trás' + CHAR(10) +
 N'4. Volte à posição inicial contraindo glúteos e posteriores',
 N'', N'posteriores'),

('ex-posteriores-mesa-flexora',
 N'Mesa Flexora',
 N'Isolamento dos posteriores de coxa com baixo risco de lesão.',
 N'Intermediário', N'Máquina',
 N'1. Deite de bruços na mesa flexora com o rolo nos tornozelos' + CHAR(10) +
 N'2. Segure as alças laterais firmemente' + CHAR(10) +
 N'3. Flexione os joelhos trazendo os calcanhares aos glúteos' + CHAR(10) +
 N'4. Retorne controladamente sem deixar o peso bater',
 N'', N'posteriores'),

-- PANTURRILHA
('ex-panturrilha-em-pe',
 N'Panturrilha em Pé',
 N'Foca principalmente no músculo gastrocnêmio.',
 N'Iniciante', N'Máquina',
 N'1. Posicione os ombros sob os apoios da máquina' + CHAR(10) +
 N'2. Apoie a ponta dos pés na plataforma' + CHAR(10) +
 N'3. Eleve os calcanhares ao máximo contraindo a panturrilha' + CHAR(10) +
 N'4. Desça controladamente alongando a panturrilha',
 N'', N'panturrilha'),

('ex-panturrilha-sentado',
 N'Panturrilha Sentado',
 N'Trabalha principalmente o músculo sóleo, complementando o trabalho em pé.',
 N'Iniciante', N'Máquina',
 N'1. Sente-se na máquina com os joelhos sob o apoio' + CHAR(10) +
 N'2. Apoie a ponta dos pés na plataforma' + CHAR(10) +
 N'3. Eleve os calcanhares contraindo o sóleo' + CHAR(10) +
 N'4. Desça controladamente alongando bem o músculo',
 N'', N'panturrilha');
GO

-- 6) Conferir
SELECT * FROM [GrupoMuscular];
SELECT COUNT(*) AS Total_Exercicios FROM [Exercício];
SELECT [Nome], [Dificuldade], [Equipamento], [GrupoMuscularId] FROM [Exercício] ORDER BY [GrupoMuscularId];
GO
