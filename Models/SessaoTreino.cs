using System.ComponentModel.DataAnnotations.Schema;

[Table("SessaoTreino")]
public class SessaoTreino
{
    public string Id { get; set; }
    [Column("PlanoTreinoId")]
    public string WorkoutPlanId { get; set; }
    [Column("Nome")]
    public string Name { get; set; }
    [Column("DiaSemana")]
    public string DayOfWeek { get; set; }

    public PlanoTreino WorkoutPlan { get; set; }
    public List<ExercicioSessao> ExerciseItems { get; set; }
}
