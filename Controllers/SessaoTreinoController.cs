using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

public class SessaoTreinoController : Controller
{
    private DatabaseContext db;
    public SessaoTreinoController(DatabaseContext db) { this.db = db; }

    private string? UserId => HttpContext.Session.GetString("UserId");
    private ActionResult RequireLogin() => RedirectToAction("Entrar", "Autenticacao");

    [HttpGet]
    public ActionResult Criar(string planId)
    {
        if (UserId == null) return RequireLogin();

        var plan = db.PlanoTreino.SingleOrDefault(p => p.Id == planId && p.UserId == UserId);
        if (plan == null) return NotFound();

        ViewBag.Plan = plan;
        return View();
    }

    [HttpPost]
    public ActionResult Criar(SessaoTreino form)
    {
        if (UserId == null) return RequireLogin();

        var plan = db.PlanoTreino.SingleOrDefault(p => p.Id == form.WorkoutPlanId && p.UserId == UserId);
        if (plan == null) return NotFound();

        form.Id = Guid.NewGuid().ToString();

        db.SessaoTreino.Add(form);
        db.SaveChanges();

        TempData["Success"] = $"Sessão \"{form.Name}\" criada!";
        return RedirectToAction("Detalhes", new { id = form.Id });
    }

    public ActionResult Detalhes(string id)
    {
        if (UserId == null) return RequireLogin();

        var session = db.SessaoTreino
            .Include(s => s.WorkoutPlan)
            .Include(s => s.ExerciseItems)
                .ThenInclude(e => e.Exercise)
                    .ThenInclude(e => e.MuscleGroup)
            .SingleOrDefault(s => s.Id == id && s.WorkoutPlan.UserId == UserId);

        if (session == null) return NotFound();

        ViewBag.AllExercises = db.Exercicio.Include(e => e.MuscleGroup)
            .OrderBy(e => e.MuscleGroupId).ThenBy(e => e.Name).ToList();

        return View(session);
    }

    [HttpPost]
    public ActionResult AdicionarExercicio(ExercicioSessao form)
    {
        if (UserId == null) return RequireLogin();

        var session = db.SessaoTreino
            .Include(s => s.WorkoutPlan)
            .SingleOrDefault(s => s.Id == form.WorkoutSessionId && s.WorkoutPlan.UserId == UserId);

        if (session == null) return NotFound();

        form.Id    = Guid.NewGuid().ToString();
        form.Order = db.ExercicioSessao.Count(e => e.WorkoutSessionId == form.WorkoutSessionId) + 1;

        db.ExercicioSessao.Add(form);
        db.SaveChanges();

        TempData["Success"] = "Exercício adicionado!";
        return RedirectToAction("Detalhes", new { id = form.WorkoutSessionId });
    }

    public ActionResult RemoverExercicio(string id)
    {
        if (UserId == null) return RequireLogin();

        var item = db.ExercicioSessao
            .Include(e => e.WorkoutSession)
                .ThenInclude(s => s.WorkoutPlan)
            .SingleOrDefault(e => e.Id == id && e.WorkoutSession.WorkoutPlan.UserId == UserId);

        if (item == null) return NotFound();

        var sessionId = item.WorkoutSessionId;
        db.ExercicioSessao.Remove(item);
        db.SaveChanges();

        TempData["Success"] = "Exercício removido.";
        return RedirectToAction("Detalhes", new { id = sessionId });
    }

    public ActionResult ExcluirSessao(string id)
    {
        if (UserId == null) return RequireLogin();

        var session = db.SessaoTreino
            .Include(s => s.WorkoutPlan)
            .SingleOrDefault(s => s.Id == id && s.WorkoutPlan.UserId == UserId);

        if (session == null) return NotFound();

        var planId = session.WorkoutPlanId;
        var name   = session.Name;
        db.SessaoTreino.Remove(session);
        db.SaveChanges();

        TempData["Success"] = $"Sessão \"{name}\" excluída.";
        return RedirectToAction("Detalhes", "Treino", new { id = planId });
    }
}
