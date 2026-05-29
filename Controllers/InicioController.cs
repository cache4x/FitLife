using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

public class InicioController : Controller
{
    private DatabaseContext db;
    public InicioController(DatabaseContext db) { this.db = db; }

    public ActionResult Index()
    {
        var userId = HttpContext.Session.GetString("UserId");
        if (userId == null) return RedirectToAction("Entrar", "Autenticacao");

        var now   = DateTime.UtcNow;
        var today = now.Date;
        var weekStart = today.AddDays(-(int)today.DayOfWeek);
        var weekEnd   = weekStart.AddDays(7);

        var upcoming = db.Agendamento
            .Include(a => a.WorkoutSession)
            .Include(a => a.Meal)
            .Where(a => a.UserId == userId && a.Date >= now && !a.Completed)
            .OrderBy(a => a.Date)
            .Take(5)
            .ToList();

        var todayMealIds = db.Agendamento
            .Where(a => a.UserId == userId && a.Type == "Refeicao"
                     && a.Date >= today && a.Date < today.AddDays(1)
                     && a.MealId != null)
            .Select(a => a.MealId)
            .ToList();

        var todayCalories = db.Refeicao
            .Where(r => todayMealIds.Contains(r.Id))
            .Sum(r => (int?)r.TotalCalories) ?? 0;

        var lastLoad = db.ProgressaoCarga
            .Include(p => p.Exercise)
            .Where(p => p.UserId == userId)
            .OrderByDescending(p => p.Date)
            .FirstOrDefault();

        var vm = new PainelViewModel
        {
            UserName       = HttpContext.Session.GetString("UserName") ?? "",
            WorkoutsThisWeek = db.Agendamento.Count(a =>
                a.UserId == userId && a.Type == "Treino"
                && a.Date >= weekStart && a.Date < weekEnd),
            TodayCalories  = todayCalories,
            LastLoadRecord = lastLoad,
            Upcoming       = upcoming,
            TotalWorkoutPlans = db.PlanoTreino.Count(p => p.UserId == userId),
            TotalDietPlans    = db.PlanoAlimentar.Count(p => p.UserId == userId),
            MuscleGroups   = db.GrupoMuscular.ToList()
        };

        return View(vm);
    }
}
