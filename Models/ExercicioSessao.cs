using System.ComponentModel.DataAnnotations.Schema;

[Table("ExercicioSessao")]
public class ExercicioSessao
{
    public string Id { get; set; }
    [Column("SessaoTreinoId")]
    public string WorkoutSessionId { get; set; }
    [Column("ExercicioId")]
    public string ExerciseId { get; set; }
    [Column("Series")]
    public int Sets { get; set; }
    [Column("Repeticoes")]
    public int Reps { get; set; }
    [Column("CargaSugerida")]
    public decimal SuggestedLoad { get; set; }
    [Column("Ordem")]
    public int Order { get; set; }

    public SessaoTreino WorkoutSession { get; set; }
    public Exercicio Exercise { get; set; }
}
