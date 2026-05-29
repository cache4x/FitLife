using System.ComponentModel.DataAnnotations.Schema;

[Table("Agendamento")]
public class Agendamento
{
    public string Id { get; set; }
    [Column("UsuarioId")]
    public string UserId { get; set; }
    [Column("Data")]
    public DateTime Date { get; set; }
    [Column("Tipo")]
    public string Type { get; set; }
    [Column("Titulo")]
    public string Title { get; set; }
    [Column("SessaoTreinoId")]
    public string? WorkoutSessionId { get; set; }
    [Column("RefeicaoId")]
    public string? MealId { get; set; }
    [Column("Concluido")]
    public bool Completed { get; set; }

    public SessaoTreino? WorkoutSession { get; set; }
    public Refeicao? Meal { get; set; }
}
