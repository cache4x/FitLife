public class PainelViewModel
{
    public string UserName { get; set; }
    public int WorkoutsThisWeek { get; set; }
    public int TodayCalories { get; set; }
    public ProgressaoCarga? LastLoadRecord { get; set; }
    public List<Agendamento> Upcoming { get; set; }
    public int TotalWorkoutPlans { get; set; }
    public int TotalDietPlans { get; set; }
    public List<GrupoMuscular> MuscleGroups { get; set; }
}
