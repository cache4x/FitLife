using Microsoft.EntityFrameworkCore;

public class DatabaseContext : DbContext
{
    public DatabaseContext(DbContextOptions<DatabaseContext> options)
        : base(options) { }

    public DbSet<Exercicio> Exercicio { get; set; }
    public DbSet<GrupoMuscular> GrupoMuscular { get; set; }
    public DbSet<Usuario> Usuario { get; set; }
    public DbSet<PlanoTreino> PlanoTreino { get; set; }
    public DbSet<SessaoTreino> SessaoTreino { get; set; }
    public DbSet<ExercicioSessao> ExercicioSessao { get; set; }
    public DbSet<PlanoAlimentar> PlanoAlimentar { get; set; }
    public DbSet<Refeicao> Refeicao { get; set; }
    public DbSet<ItemRefeicao> ItemRefeicao { get; set; }
    public DbSet<Agendamento> Agendamento { get; set; }
    public DbSet<ProgressaoCarga> ProgressaoCarga { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // ExercicioSessao → Exercicio não deve cascatear delete
        modelBuilder.Entity<ExercicioSessao>()
            .HasOne(e => e.Exercise)
            .WithMany()
            .HasForeignKey(e => e.ExerciseId)
            .OnDelete(Microsoft.EntityFrameworkCore.DeleteBehavior.Restrict);

        modelBuilder.Entity<GrupoMuscular>().HasData(
            new GrupoMuscular { Id = "peito",       Name = "Peito",       Region = "Frente", IconEmoji = "💪" },
            new GrupoMuscular { Id = "ombros",      Name = "Ombros",      Region = "Frente", IconEmoji = "🏋️" },
            new GrupoMuscular { Id = "biceps",      Name = "Bíceps",      Region = "Frente", IconEmoji = "💪" },
            new GrupoMuscular { Id = "abdomen",     Name = "Abdômen",     Region = "Frente", IconEmoji = "🔥" },
            new GrupoMuscular { Id = "quadriceps",  Name = "Quadríceps",  Region = "Frente", IconEmoji = "🦵" },
            new GrupoMuscular { Id = "costas",      Name = "Costas",      Region = "Costas", IconEmoji = "🔙" },
            new GrupoMuscular { Id = "triceps",     Name = "Tríceps",     Region = "Costas", IconEmoji = "💪" },
            new GrupoMuscular { Id = "gluteos",     Name = "Glúteos",     Region = "Costas", IconEmoji = "🍑" },
            new GrupoMuscular { Id = "posteriores", Name = "Posteriores", Region = "Costas", IconEmoji = "🦵" },
            new GrupoMuscular { Id = "panturrilha", Name = "Panturrilha", Region = "Costas", IconEmoji = "🦵" }
        );

        modelBuilder.Entity<Exercicio>().HasData(
            // PEITO
            new Exercicio { Id = "ex-peito-supino",    Name = "Supino Reto",
                Description  = "Exercício clássico para desenvolvimento do peitoral maior, ombros e tríceps.",
                Difficulty   = "Iniciante", Equipment = "Barra",
                Steps        = "1. Deite no banco com os pés apoiados no chão\n2. Segure a barra com pegada um pouco mais larga que os ombros\n3. Desça a barra controladamente até tocar o peito\n4. Empurre a barra de volta até estender os braços",
                ImageUrl = "", MuscleGroupId = "peito" },
            new Exercicio { Id = "ex-peito-crucifixo", Name = "Crucifixo com Halteres",
                Description  = "Exercício de isolamento focado no peitoral, com grande amplitude de movimento.",
                Difficulty   = "Intermediário", Equipment = "Halteres",
                Steps        = "1. Deite no banco com um halter em cada mão\n2. Estenda os braços acima do peito com leve flexão dos cotovelos\n3. Abra os braços lateralmente até sentir alongamento no peito\n4. Retorne à posição inicial contraindo o peitoral",
                ImageUrl = "", MuscleGroupId = "peito" },
            // OMBROS
            new Exercicio { Id = "ex-ombros-desenvolvimento",    Name = "Desenvolvimento Militar",
                Description  = "Exercício composto que trabalha principalmente o deltoide anterior e medial.",
                Difficulty   = "Intermediário", Equipment = "Barra",
                Steps        = "1. Em pé, segure a barra na altura dos ombros\n2. Mantenha o core contraído e a coluna neutra\n3. Empurre a barra para cima até estender os braços\n4. Desça controladamente até a posição inicial",
                ImageUrl = "", MuscleGroupId = "ombros" },
            new Exercicio { Id = "ex-ombros-elevacao-lateral",   Name = "Elevação Lateral",
                Description  = "Isolamento do deltoide medial para construção de ombros largos.",
                Difficulty   = "Iniciante", Equipment = "Halteres",
                Steps        = "1. Em pé, segure um halter em cada mão ao lado do corpo\n2. Mantenha leve flexão nos cotovelos\n3. Eleve os braços lateralmente até a altura dos ombros\n4. Desça controladamente sem balançar o corpo",
                ImageUrl = "", MuscleGroupId = "ombros" },
            // BÍCEPS
            new Exercicio { Id = "ex-biceps-rosca-direta", Name = "Rosca Direta",
                Description  = "Exercício clássico para hipertrofia do bíceps braquial.",
                Difficulty   = "Iniciante", Equipment = "Barra",
                Steps        = "1. Em pé, segure a barra com pegada supinada\n2. Mantenha os cotovelos junto ao corpo\n3. Flexione os cotovelos elevando a barra até a altura do peito\n4. Desça controladamente sem balançar",
                ImageUrl = "", MuscleGroupId = "biceps" },
            new Exercicio { Id = "ex-biceps-martelo",      Name = "Rosca Martelo",
                Description  = "Trabalha o bíceps e o braquial, dando volume ao braço.",
                Difficulty   = "Iniciante", Equipment = "Halteres",
                Steps        = "1. Em pé, segure um halter em cada mão com pegada neutra\n2. Mantenha os cotovelos colados ao tronco\n3. Flexione os cotovelos como se estivesse martelando\n4. Retorne à posição inicial controladamente",
                ImageUrl = "", MuscleGroupId = "biceps" },
            // ABDÔMEN
            new Exercicio { Id = "ex-abdomen-prancha", Name = "Prancha",
                Description  = "Exercício isométrico que fortalece todo o core, sem impacto.",
                Difficulty   = "Iniciante", Equipment = "Peso Corporal",
                Steps        = "1. Apoie os antebraços e as pontas dos pés no chão\n2. Mantenha o corpo alinhado da cabeça aos calcanhares\n3. Contraia o abdômen e os glúteos\n4. Sustente a posição por 30 a 60 segundos",
                ImageUrl = "", MuscleGroupId = "abdomen" },
            new Exercicio { Id = "ex-abdomen-supra",   Name = "Abdominal Supra",
                Description  = "Movimento básico de contração do reto abdominal.",
                Difficulty   = "Iniciante", Equipment = "Peso Corporal",
                Steps        = "1. Deite com os joelhos flexionados e os pés no chão\n2. Coloque as mãos atrás da cabeça sem puxar o pescoço\n3. Eleve o tronco contraindo o abdômen\n4. Desça controladamente até quase encostar no chão",
                ImageUrl = "", MuscleGroupId = "abdomen" },
            // QUADRÍCEPS
            new Exercicio { Id = "ex-quadriceps-agachamento", Name = "Agachamento Livre",
                Description  = "Considerado o rei dos exercícios para membros inferiores.",
                Difficulty   = "Avançado", Equipment = "Barra",
                Steps        = "1. Posicione a barra no trapézio com os pés afastados na largura dos ombros\n2. Desça flexionando joelhos e quadris simultaneamente\n3. Mantenha a coluna ereta e o peito aberto\n4. Suba empurrando o chão com os calcanhares",
                ImageUrl = "", MuscleGroupId = "quadriceps" },
            new Exercicio { Id = "ex-quadriceps-leg-press",   Name = "Leg Press 45º",
                Description  = "Excelente para iniciantes e ideal para sobrecarga sem comprometer a coluna.",
                Difficulty   = "Intermediário", Equipment = "Máquina",
                Steps        = "1. Sente-se na máquina com as costas bem apoiadas\n2. Posicione os pés na plataforma na largura dos ombros\n3. Desça flexionando os joelhos até 90 graus\n4. Empurre a plataforma de volta sem travar os joelhos",
                ImageUrl = "", MuscleGroupId = "quadriceps" },
            // COSTAS
            new Exercicio { Id = "ex-costas-barra-fixa",     Name = "Barra Fixa",
                Description  = "Exercício composto que trabalha grande dorsal, bíceps e antebraços.",
                Difficulty   = "Avançado", Equipment = "Peso Corporal",
                Steps        = "1. Pendure-se na barra com pegada pronada e mais aberta que os ombros\n2. Contraia o core e puxe o corpo para cima\n3. Eleve até o queixo passar a barra\n4. Desça controladamente até estender os braços",
                ImageUrl = "", MuscleGroupId = "costas" },
            new Exercicio { Id = "ex-costas-remada-curvada", Name = "Remada Curvada",
                Description  = "Exercício essencial para desenvolvimento da espessura do dorso.",
                Difficulty   = "Intermediário", Equipment = "Barra",
                Steps        = "1. Em pé, com tronco inclinado a 45 graus e coluna neutra\n2. Segure a barra com pegada pronada\n3. Puxe a barra em direção ao abdômen\n4. Desça controladamente estendendo os braços",
                ImageUrl = "", MuscleGroupId = "costas" },
            // TRÍCEPS
            new Exercicio { Id = "ex-triceps-pulley",  Name = "Tríceps na Polia",
                Description  = "Exercício de isolamento com corda ou barra na polia alta.",
                Difficulty   = "Iniciante", Equipment = "Cabos",
                Steps        = "1. Em pé de frente para a polia alta, segure a barra\n2. Mantenha os cotovelos colados ao tronco\n3. Estenda os braços empurrando a barra para baixo\n4. Retorne controladamente sem afastar os cotovelos",
                ImageUrl = "", MuscleGroupId = "triceps" },
            new Exercicio { Id = "ex-triceps-frances", Name = "Tríceps Francês",
                Description  = "Foca na cabeça longa do tríceps com grande alongamento.",
                Difficulty   = "Intermediário", Equipment = "Halteres",
                Steps        = "1. Deite no banco segurando um halter com as duas mãos acima da cabeça\n2. Mantenha os cotovelos apontados para o teto\n3. Flexione os cotovelos descendo o halter atrás da cabeça\n4. Estenda os braços de volta à posição inicial",
                ImageUrl = "", MuscleGroupId = "triceps" },
            // GLÚTEOS
            new Exercicio { Id = "ex-gluteos-elevacao-pelvica", Name = "Elevação Pélvica (Hip Thrust)",
                Description  = "O melhor exercício para hipertrofia dos glúteos.",
                Difficulty   = "Iniciante", Equipment = "Peso Corporal",
                Steps        = "1. Apoie a parte superior das costas em um banco\n2. Flexione os joelhos com os pés apoiados no chão\n3. Eleve o quadril contraindo os glúteos\n4. Desça controladamente sem encostar totalmente no chão",
                ImageUrl = "", MuscleGroupId = "gluteos" },
            new Exercicio { Id = "ex-gluteos-polia",            Name = "Glúteo na Polia",
                Description  = "Isolamento dos glúteos com sobrecarga progressiva.",
                Difficulty   = "Intermediário", Equipment = "Cabos",
                Steps        = "1. Prenda a caneleira no tornozelo e na polia baixa\n2. Em pé, segure-se no suporte para equilíbrio\n3. Estenda a perna para trás contraindo o glúteo\n4. Retorne controladamente à posição inicial",
                ImageUrl = "", MuscleGroupId = "gluteos" },
            // POSTERIORES
            new Exercicio { Id = "ex-posteriores-stiff",        Name = "Stiff",
                Description  = "Exercício composto focado em posteriores de coxa e glúteos.",
                Difficulty   = "Avançado", Equipment = "Barra",
                Steps        = "1. Em pé, segure a barra com pegada pronada à frente do corpo\n2. Mantenha leve flexão nos joelhos\n3. Incline o tronco à frente empurrando o quadril para trás\n4. Volte à posição inicial contraindo glúteos e posteriores",
                ImageUrl = "", MuscleGroupId = "posteriores" },
            new Exercicio { Id = "ex-posteriores-mesa-flexora", Name = "Mesa Flexora",
                Description  = "Isolamento dos posteriores de coxa com baixo risco de lesão.",
                Difficulty   = "Intermediário", Equipment = "Máquina",
                Steps        = "1. Deite de bruços na mesa flexora com o rolo nos tornozelos\n2. Segure as alças laterais firmemente\n3. Flexione os joelhos trazendo os calcanhares aos glúteos\n4. Retorne controladamente sem deixar o peso bater",
                ImageUrl = "", MuscleGroupId = "posteriores" },
            // PANTURRILHA
            new Exercicio { Id = "ex-panturrilha-em-pe",   Name = "Panturrilha em Pé",
                Description  = "Foca principalmente no músculo gastrocnêmio.",
                Difficulty   = "Iniciante", Equipment = "Máquina",
                Steps        = "1. Posicione os ombros sob os apoios da máquina\n2. Apoie a ponta dos pés na plataforma\n3. Eleve os calcanhares ao máximo contraindo a panturrilha\n4. Desça controladamente alongando a panturrilha",
                ImageUrl = "", MuscleGroupId = "panturrilha" },
            new Exercicio { Id = "ex-panturrilha-sentado", Name = "Panturrilha Sentado",
                Description  = "Trabalha principalmente o músculo sóleo, complementando o trabalho em pé.",
                Difficulty   = "Iniciante", Equipment = "Máquina",
                Steps        = "1. Sente-se na máquina com os joelhos sob o apoio\n2. Apoie a ponta dos pés na plataforma\n3. Eleve os calcanhares contraindo o sóleo\n4. Desça controladamente alongando bem o músculo",
                ImageUrl = "", MuscleGroupId = "panturrilha" }
        );
    }
}
