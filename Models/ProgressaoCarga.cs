using System.ComponentModel.DataAnnotations.Schema;

[Table("ProgressaoCarga")]
public class ProgressaoCarga
{
    public string Id { get; set; }
    [Column("UsuarioId")]
    public string UserId { get; set; }
    [Column("ExercicioId")]
    public string ExerciseId { get; set; }
    [Column("Data")]
    public DateTime Date { get; set; }
    [Column("Series")]
    public int Sets { get; set; }
    [Column("Repeticoes")]
    public int Reps { get; set; }
    [Column("Carga")]
    public decimal Load { get; set; }
    [Column("Observacao")]
    public string? Notes { get; set; }

    public Exercicio? Exercise { get; set; }
}
